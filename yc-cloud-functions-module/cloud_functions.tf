resource "yandex_function" "test_function" {
  name               = "yc-function-example"
  description        = "this is the yc cloud function for tf-module"
  user_hash          = "yc-defined-string-for-tf-module" # User-defined string for current function version. User must change this string any times when function changed. Function will be updated when hash is changed.
  runtime            = "bash"
  entrypoint         = "handler.sh"
  memory             = "128"
  execution_timeout  = "10"
  service_account_id = var.default_service_account_id
  tags               = ["yc_tag"]
  secrets {
    id = "${yandex_lockbox_secret.secret.id}"
    version_id = "${yandex_lockbox_secret_version.version.id}"
    key = "yc-key"
    environment_variable = "YCKEY_ENV_VAR"
  }

  content {
    zip_filename = "handler.zip"
  }
  # loggroup_id = "${yandex_logging_group.yc_log_group.id}"
}

resource "yandex_function_trigger" "yc_trigger" {
  name        = "yc-function-trigger"
  description = "this is the yc cloud function trigger for tf-module"
  timer {
    cron_expression = "*/5 * ? * * *"
  }
  function {
    id = "${yandex_function.test_function.id}"
    service_account_id = var.default_service_account_id
  }
}

resource "yandex_function_iam_binding" "function_iam" {
  function_id = "${yandex_function.test_function.id}"
  role        = "serverless.functions.invoker"

  members = [
    "system:allUsers",
  ]
}