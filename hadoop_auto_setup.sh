#!/bin/bash
docker run -dit --name master --network hadoop-cluster -p 8088:8088 --ip 10.0.2.2 --add-host=Master:10.0.2.2 --add-host=Slave01:10.0.2.3 --add-host=Slave02:10.0.2.4 --add-host=Slave03:10.0.2.5 larkjh/dnlab_hadoop:complete
docker run -dit --name slave01 --network hadoop-cluster --ip 10.0.2.3 --add-host=Master:10.0.2.2 --add-host=Slave01:10.0.2.3 --add-host=Slave02:10.0.2.4 --add-host=Slave03:10.0.2.5 larkjh/dnlab_hadoop:complete
docker run -dit --name slave02 --network hadoop-cluster --ip 10.0.2.3 --add-host=Master:10.0.2.2 --add-host=Slave01:10.0.2.3 --add-host=Slave02:10.0.2.4 --add-host=Slave03:10.0.2.5 larkjh/dnlab_hadoop:complete
docker run -dit --name slave03 --network hadoop-cluster --ip 10.0.2.3 --add-host=Master:10.0.2.2 --add-host=Slave01:10.0.2.3 --add-host=Slave02:10.0.2.4 --add-host=Slave03:10.0.2.5 larkjh/dnlab_hadoop:complete

# How to access container?
# docker exec -it <container_name> /bin/bash

# How to stop container?
# docker stop <container_name>

# How to remove container?
# docker rm <container_name>
