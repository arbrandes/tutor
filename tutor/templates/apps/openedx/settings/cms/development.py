# -*- coding: utf-8 -*-
import os
from cms.envs.devstack import *

{% include "apps/openedx/settings/partials/common_cms.py" %}

LMS_BASE = "{{ LMS_HOST }}:8000"
LMS_ROOT_URL = "http://" + LMS_BASE

CMS_BASE = "{{ CMS_HOST }}:8001"
CMS_ROOT_URL = "http://" + CMS_BASE

MEILISEARCH_PUBLIC_URL = "{{ MEILISEARCH_PUBLIC_URL }}:7700"

# Authentication
SOCIAL_AUTH_EDX_OAUTH2_KEY = "{{ CMS_OAUTH2_KEY_SSO_DEV }}"
SOCIAL_AUTH_EDX_OAUTH2_PUBLIC_URL_ROOT = LMS_ROOT_URL

# Setup correct webpack configuration file for development
WEBPACK_CONFIG_PATH = "webpack.dev.config.js"

{{ patch("openedx-development-settings") }}
{{ patch("openedx-cms-development-settings") }}
