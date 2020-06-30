require 'spec_helper'

describe ActiveGraph::Transactions do
  let(:read_query) { 'RETURN 1' }
  let(:write_query) { 'CREATE (n:Student) RETURN count(n)' }

  before do
    clear_model_memory_caches
    stub_node_class('Student')
  end

  describe '.transaction' do
    context 'driver' do

      it 'executes read' do
        expect(ActiveGraph::Base.transaction { |tx| tx.run(read_query).single.first }).to eq 1
      end

      it 'executes write' do
        expect(ActiveGraph::Base.transaction { |tx| tx.run(write_query).single.first }).to eq 1
      end
    end

    context 'DSL' do

      # this gives: ActiveGraph::DeprecatedSchemaDefinitionError:
      # Some schema elements were defined by the model (which is no longer
      # supported), but they do not exist in the database.  Run the following
      # to create them if you haven't already:
      # rake neo4j:generate_schema_migration[constraint,Student,uuid]
      #
      # That's odd, since stub_node_class('Student') causes the query
      # CREATE CONSTRAINT ON (n:`Student`) ASSERT n.`uuid` IS UNIQUE
      #
      # Ah, that's validate_model_schema! in lib/active_graph/model_schema.rb
      # and I think this is because Memgraph constraints aren't reported as
      # indexes, in fact I think just implementing constraints would fix this
      # ... so do that

      it 'executes read' do
        expect(ActiveGraph::Base.transaction { Student.count }).to eq 0
      end

      it 'executes write' do
        expect(ActiveGraph::Base.transaction { Student.create }).to be_a Student
      end
    end
  end

  describe '.write_transaction' do
    context 'driver' do
      it 'executes read' do
        expect(ActiveGraph::Base.write_transaction { |tx| tx.run(read_query).single.first }).to eq 1
      end

      it 'executes write' do
        expect(ActiveGraph::Base.write_transaction { |tx| tx.run(write_query).single.first }).to eq 1
      end
    end

    context 'DSL' do
      it 'executes read' do
        expect(ActiveGraph::Base.write_transaction { Student.count }).to eq 0
      end

      it 'executes write' do
        expect(ActiveGraph::Base.write_transaction { Student.create }).to be_a Student
      end
    end
  end

  describe '.read_transaction' do
    context 'driver' do
      it 'executes read' do
        expect(ActiveGraph::Base.read_transaction { |tx| tx.run(read_query).single.first }).to eq 1
      end
    end

    context 'DSL' do
      it 'executes read' do
        expect(ActiveGraph::Base.read_transaction { Student.count }).to eq 0
      end
    end
  end


  describe '.session' do
    it 'allows write on implicitly writable' do
      expect { ActiveGraph::Base.session { ActiveGraph::Base.transaction { Student.create } } }.not_to raise_error
    end

    it 'allows write on explicitely writable' do
      expect do
        ActiveGraph::Base.session(Neo4j::Driver::AccessMode::WRITE) { ActiveGraph::Base.transaction { Student.create } }
      end.not_to raise_error
    end

    it 'returns and accepts bookmarks' do
      expect do
        bookmark = ActiveGraph::Base.session do
          ActiveGraph::Base.write_transaction { Student.create }
          ActiveGraph::Base.write_transaction { Student.create }
        end
        ActiveGraph::Base.session(bookmark) { ActiveGraph::Base.read_transaction { Student.count } }
      end.not_to raise_error
    end

    # this fails due to version not be implemented, and this being
    # specifically the Neo4j version

    it 'can mix DSL with pure driver ' do
      skip 'version' if ActiveGraph::DBType.memgraph?
      expect do
        ActiveGraph::Base.session do |session|
          ActiveGraph::Base.write_transaction do |tx|
            tx.run(read_query)
            Student.create
          end
          session.write_transaction { |tx| tx.run(write_query) }
          if ActiveGraph::Base.version >= '3.5'
            session.run(read_query, {}, timeout: 1.minute)
          else
            session.run(read_query)
          end
        end
      end.not_to raise_error
    end

    it 'can nest transactions' do
      expect do
        ActiveGraph::Base.session do
          ActiveGraph::Base.write_transaction do |outer_tx|
            ActiveGraph::Transaction.transaction do |inner_tx|
              expect(inner_tx).to eq outer_tx # regardless by which module accessed
            end
          end
        end
      end
    end

    it 'can call transaction on Node' do
      Student.session do
        Student.write_transaction do |tx|
          Student.create
          expect(Student.count).to eq 1
        end
      end
    end
  end
end
