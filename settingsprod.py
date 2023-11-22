import os
#import dotenv
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/4.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-nes9=s+y+n_$ko5(xsxiba=qu8x%f$gntln1k08e5$n9s18&(0'

# STRIPE
STRIPE_PUB_KEY = 'pk_test_51NIt1uAK8IvkifNkVgryzdK2EBF0UR2utHehxc8AnKunCIntPAZmF1hJMBiymnJB6QPMapIBHIRpZDmjAfL0gNvW00LqnQCSNS'
STRIPE_SECRET_KEY = 'sk_test_51NIt1uAK8IvkifNkc53MHYiZZyZRWiMRsMXuLRucUNgvSPm9LiNXF1X5fYtVtuIEa11CFvHZI7amftiwf1vNKQAf00ypRQ7t0E'
STRIPE_WEBHOOK_KEY = 'whsec_d2d1cb0d6589e016ee287ea5ec7d9fab55d0a244ee711e560b09f8f9325181d4'


# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = [
    'www.mapchi.com',
    'mapchi.com',
    'api.mapchi.com',
    'staging.mapchi.com',
    'prometheus1001.myqnapcloud.com',
    '143.110.174.196',
]

CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'token',
    ]

CORS_ALLOW_ALL_ORIGINS = True
