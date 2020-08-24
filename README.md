Laravel 5.7 container image
================

This container image includes PHP 7.2 (gd, pdo_mysql, phpredis) as a base image for your Laravel 5.7 applications.

Description
-----------

Laravel 5.7 available as container is a base platform for
running various Laravel 5.7 frameworks.
Laravel is a web application framework with expressive, elegant syntax.
We’ve already laid the foundation freeing you to create without sweating the small things.

Environment variables
---------------------

The following environment variables set their equivalent property value in the .env* file:
* **LARAVEL_SECRETS**
  * Set this to a empty value to skip sets the .env values with the [docker secret](https://docs.docker.com/engine/swarm/secrets/#how-docker-manages-secrets) on startup.
  * Default: 1
* **LARAVEL_SECRET_{{LARAVEL_ENV_KEY}}**
  * Set this variable to use the docker secret file content to automatically update the *LARAVEL_ENV_KEY* in *LARAVEL_ENV_FILES* on startup.
* **LARAVEL_ENV_EXAMPLE_FILES**
  * This variable can be used to specify the env example files which will automatically be renamed to .env. Otherwise is contained.
  * Default: .env.example
* **LARAVEL_ENV_FILES**
  * This variable can be used to specify the env files which needs to be replaced with the docker secret is contained.
  * Default: .env
* **LARAVEL_OPTIMIZE**
  * Set this to a empty value to skip processing ```php artisan optimize```.
  * Default: 0   
* **LARAVEL_CONFIG_CACHE**
  * Set this to a empty value to skip processing [optimizing configuration](https://laravel.com/docs/5.7/deployment#optimizing-configuration-loading)
  * Default: 0
* **LARAVEL_ROUTE_CACHE**
  * Set this to a empty value to skip processing
  * Default: 0
