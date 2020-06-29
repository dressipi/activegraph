module ActiveGraph
  module Core
    class Label
      module Neo4j

        def self.prepended(cls)
          cls.extend(ClassMethods)
        end

        module ClassMethods

          def list_constraints_cypher
            'CALL db.constraints'
          end

          def drop_constraint_target(record)
            if record.keys.include?(:name) then
              "CONSTRAINT #{record[:name]}"
            else
              record[:description]
            end
          end
        end
      end
    end
  end
end
