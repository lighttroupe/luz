echo
echo '### Getting needed software to build ffmpeg video support...'
echo
sudo apt-get -y install ruby ruby-dev libavformat-dev libavcodec-dev libavutil-dev libswscale-dev

echo
echo '### Generating makefile...'
echo
ruby extconf.rb

echo
echo '### Running makefile...'
echo
rm -f ffmpeg.so
make
