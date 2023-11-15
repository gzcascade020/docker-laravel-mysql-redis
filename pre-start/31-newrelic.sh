NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY:-}
NEW_RELIC_APPNAME=${NEW_RELIC_APPNAME:-}
NEW_RELIC_HOST=${NEW_RELIC_HOST:-}
NEW_RELIC_DAEMON_PROXY=${NEW_RELIC_DAEMON_PROXY:-}
NEW_RELIC_INI=${NEW_RELIC_INI:-}

function configuration_newrelic {
    log_info "Configuring newrelic agent..."

    sed -i -e "s/REPLACE_WITH_REAL_KEY/${NEW_RELIC_LICENSE_KEY}/" "${NEW_RELIC_INI}"
    sed -i -e "s/REPLACE_WITH_REAL_KEY/${NEW_RELIC_LICENSE_KEY}/" "${NEW_RELIC_INI}"
    sed -i -e "s/newrelic.appname[[:space:]]=[[:space:]].*/newrelic.appname = \"${NEW_RELIC_APPNAME}\"/" "${NEW_RELIC_INI}"

    sed -i -e "\$anewrelic.daemon.address = \"${NEW_RELIC_HOST}\"" "${NEW_RELIC_INI}"
    sed -i -e '$anewrelic.application_logging.enabled = true' "${NEW_RELIC_INI}"
    sed -i -e '$anewrelic.application_logging.metrics.enabled = true' "${NEW_RELIC_INI}"
    sed -i -e '$anewrelic.application_logging.forwarding.enabled = true' "${NEW_RELIC_INI}"

    if [ ! -z "${NEW_RELIC_DAEMON_PROXY}" ]
    then
        sed -i -e "\$anewrelic.daemon.proxy = \"${NEW_RELIC_DAEMON_PROXY}\"" "${NEW_RELIC_INI}"
    fi
}

if [ ! -z "${NEW_RELIC_LICENSE_KEY}" ] && [ ! -z "${NEW_RELIC_APPNAME}" ]
then
    configuration_newrelic
fi
