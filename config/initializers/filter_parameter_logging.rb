Rails.application.config.filter_parameters += %i[
  passw email token secret key credential authorization encrypted_password reset_password
]
