require "bq_fake_view/version"

require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'google/apis/bigquery_v2'

class BqFakeView
  class CastError < StandardError; end
  class FieldNotFound < StandardError; end

  def initialize(auth)
    @bigquery = Google::Apis::BigqueryV2::BigqueryService.new
    @bigquery.authorization = auth
    @bigquery
  end

  def create_view(project_id, dataset_id, name, rows, schema)
    query = view_query(rows, schema)

    @bigquery.insert_table(project_id, dataset_id, Google::Apis::BigqueryV2::Table.new({
      table_reference: {
        project_id: project_id,
        dataset_id: dataset_id,
        table_id: name,
      },
      view: {
        query: query
      },
    }))
  end

  def view_query(rows, schema)
    subqueries = rows.map do |r|
      "(#{sql_from_hash(r, schema)})"
    end
    "SELECT * FROM #{subqueries.join(", ")}"
  end

  def sql_from_hash(row, schema)
    cols = row.map do |k, v|
      field = schema.find { |f| f[:name].to_s == k.to_s }
      raise FieldNotFound, "#{k} is not found from schema" unless field
      "#{cast_to_sql_value(v, field[:type])} as #{k}"
    end

    "SELECT #{cols.join(", ")}"
  end

  private

  def cast_to_sql_value(value, type)
    case value
    when String
      %Q{"#{value.gsub('\\', '\\\\\\\\').gsub(/"/, %q{\"})}"}
    when Numeric
      value.to_s
    when Time, Date
      "TIMESTAMP(\"#{value.to_s(:db)}\")"
    when nil
      "CAST(NULL AS #{type})"
    else
      raise CastError, "#{value} is unsupported type"
    end
  end
end
