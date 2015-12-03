# Patch AR to connect to MySQL 5.7 servers...
# https://github.com/rails/rails/pull/13247#issuecomment-32425844
class ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
  NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
end
