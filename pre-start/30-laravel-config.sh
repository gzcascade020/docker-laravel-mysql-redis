log_info 'Processing laravel configuration ...'

LARAVEL_SECRETS=${LARAVEL_SECRETS:-1}
LARAVEL_ENV_EXAMPLE_FILES=${LARAVEL_ENV_EXAMPLE_FILES:-.env.example}
LARAVEL_ENV_FILES=${LARAVEL_ENV_FILES:-.env}
LARAVEL_OPTIMIZE=${LARAVEL_OPTIMIZE:-}
LARAVEL_CONFIG_CACHE=${LARAVEL_CONFIG_CACHE:-}
LARAVEL_ROUTE_CACHE=${LARAVEL_ROUTE_CACHE:-}

# Copy .env*.example files to .env*
function process_laravel_env_files {
    local example_files filename
    IFS=':' read -r -a example_files <<<"${LARAVEL_ENV_EXAMPLE_FILES}"
    if [ ${#example_files[@]} -ne 0 ]
    then
        log_info 'Processing laravel env files ...'
        for example_file in "${example_files[@]}"
        do
            filename="${example_file%.example}"
            if [ -f "${APP_DATA}/${example_file}" ] && [ ! -f "${APP_DATA}/${filename}" ]
            then
                log_and_run cp "${APP_DATA}/${example_file}" "${APP_DATA}/${filename}"
            fi
        done
    fi
}

function get_env_files {
    local files result
    IFS=':' read -r -a files <<<"${LARAVEL_ENV_FILES}"
    for file in "${files[@]}"
    do
        [[ -f "${file}" ]] && result="${result} ${file}"
    done
    echo ${result}
}

# Replace env values with the docker secrets
function process_laravel_docker_secrets {
    local env_files=$(get_env_files)
    if [ "${LARAVEL_SECRETS}" -ne 0 ] && [ ! -z "${env_files}" ]
    then
        local secret_file target val
        log_info 'Processing laravel env docker secrets ...'
        for secret in "${!LARAVEL_SECRET_@}"
        do
            secret_file=$(printenv "${secret}")
            if [ -r "${secret_file}" ]
            then
                target="${secret#LARAVEL_SECRET_}"
                val=$(cat "${secret_file}")
                log_info "Running sed -i -e \"s#^${target}=.*\$#${target}=******#g\" ${env_files}"
                sed -i -e "s#^${target}=.*\$#${target}=${val}#g" ${env_files}
            fi
        done
    fi
}

function artisan_optimize {
    if [ ! -z "${LARAVEL_OPTIMIZE}" ]
    then
        log_and_run php artisan optimize
    fi
}

function artisan_config_cache {
    if [ -z "${LARAVEL_OPTIMIZE}" ] && [ ! -z "${LARAVEL_CONFIG_CACHE}" ]
    then
        log_and_run php artisan config:cache
    fi    
}

function artisan_route_cache {
    if [ -z "${LARAVEL_OPTIMIZE}" ] && [ ! -z "${LARAVEL_ROUTE_CACHE}" ]
    then
        log_and_run php artisan route:cache
    fi    
}
    
process_laravel_env_files
process_laravel_docker_secrets
artisan_optimize
artisan_config_cache
artisan_route_cache
