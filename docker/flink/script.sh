docker cp d05feb218838:/opt/flink/conf ./
bin/sql-client.sh embedded -d /opt/flink/conf/sql.my.yaml -l /opt/flink/sql-lib/

