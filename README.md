# docker-container-monitor
Bash monitoring script that monitors docker containers on a server and triggers OpsBridge server to create an alert if an OpsBridge agent is installed on the server. Raises critical alert on OpsBridge and clears if the container are up. In addition, sends an email to given addresses and logs all containers to a given path.
