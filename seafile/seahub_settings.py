# -*- coding: utf-8 -*-
SECRET_KEY = "b'ilfo_)m%u$epj1=h9@*7hrry(c$yrk@5zn%c5j_95hl=^l#q2z'"
SERVICE_URL = "http://192.168.1.11/"

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'seahub_db',
        'USER': 'seafile',
        'PASSWORD': 'N0=22Sy-Fa?42',
        'HOST': '192.168.1.13',
        'PORT': '3306',
        'OPTIONS': {'charset': 'utf8mb4'},
    }
}

