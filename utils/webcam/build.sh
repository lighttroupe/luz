echo 'Getting needed software to build V4L...'
sudo apt-get -y install ruby ruby-dev libv4l-dev

echo
echo 'Generating makefile...'
ruby extconf.rb

echo
echo 'Building V4L for Ruby...'
rm -f video4linux2.so
make
