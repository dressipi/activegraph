module ActiveGraph
  module Core
    class Label
      module Memgraph

        def self.included(cls)
          cls.extend(ClassMethods)
        end

        module ClassMethods

          def list_constraints_cypher
            'SHOW CONSTRAINT INFO'
          end

          def drop_constraint_target(record)
            case type = record['constraint type'.to_sym]
            when 'unique'
              format(
                'CONSTRAINT ON (n:`%s`) ASSERT %s IS UNIQUE',
                record[:label],
                record[:properties]
                  .split(/,/)
                  .map { |property| "n.#{property}" }
                  .join(', ')
              )
            else
              raise RuntimeError, "unknown constraint type #{type}"
            end
          end
        end
      end
    end
  end
end
