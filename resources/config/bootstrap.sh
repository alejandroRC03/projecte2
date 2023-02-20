set -e
set -u

SUPERVISOR_PARAMS='-c /etc/supervisor/supervisord.conf'

if [ "$(ls /resources/config/init/)" ]; then
  for init in /resources/config/init/*.sh; do
    . $init
  done
fi

apache_config_file=/resources/config/apache-config.sh
if [ -f "$apache_config_file" ]; then
	chmod +x $apache_config_file
	$apache_config_file
fi

if test -t 0; then
  # Run supervisord detached...
  supervisord $SUPERVISOR_PARAMS
  
  if [[ $@ ]]; then 
    eval $@
  else 
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi

else
  if [[ $@ ]]; then 
    eval $@
  fi
  supervisord -n $SUPERVISOR_PARAMS
fi
