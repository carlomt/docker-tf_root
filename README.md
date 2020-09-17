# docker-tf_root

Contains Tensorflow 2.3.0 and ROOT 6.22.3

It's suggested to run as:
`docker run --user $(id -u):$(id -g)  --volume="/home/$USER:/home/$USER" --volume="/etc/group:/etc/group:ro" --volume="/etc/passwd:/etc/passwd:ro" --volume="/etc/shadow:/etc/shadow:ro" --gpus "device=N" -it --rm carlomt/tf_root`

