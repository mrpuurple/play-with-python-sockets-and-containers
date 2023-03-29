# Get the latest base image for python
FROM python:alpine3.17
# Put files at the image '/server/' folder.
ADD ipc_multiconn_server.py /server/
# '/server/' is base directory
WORKDIR /server/
# By default, the EXPOSE instruction does not expose
# the container’s ports to be accessible from the host.
# In other words, it only makes the stated ports
# available for inter-container interaction. 
EXPOSE 8080/udp
EXPOSE 8080/tcp
# Execute the script
CMD [ "python3", "/server/ipc_multiconn_server.py"]