# Settings for deployment

from os.path import join, dirname, basename
import re

PRAKTOMAT_PATH = dirname(dirname(dirname(__file__)))

PRAKTOMAT_ID = basename(dirname(PRAKTOMAT_PATH))

match = re.match(r'''
	(?:praktomat_)?
	(?P<oop>OOP_)?
	(?P<swprojekt>SW_Projekt_)?
	(?P<year>\d+)_
	(?P<semester>WS|SS)
	''', PRAKTOMAT_ID, flags=re.VERBOSE)

if match:
	if match.group('oop') is not None:
		SITE_NAME = 'OOP Java Informatik '
	elif match.group('swprojekt') is not None:
		SITE_NAME = 'Softwareprojekt '
	else:
		SITE_NAME = 'Programmieren '

	year = int(match.group('year'))
	if match.group('semester') == "WS":
		SITE_NAME += "Wintersemester %d/%d" % (year, year+1)
	else:
		SITE_NAME += "Sommersemester %d" % year

else:
    SITE_NAME = PRAKTOMAT_ID

# The name that will be displayed on top of the page and in emails.
#SITE_NAME = 'Praktomat der Frankfurt University of Applied Sciences'

BASE_HOST = 'http://10.18.2.59:8000'
BASE_PATH = '/' + PRAKTOMAT_ID + '/'

# URL to use when referring to static files.
STATIC_URL = BASE_PATH + 'static/'
STATIC_ROOT = join(dirname(PRAKTOMAT_PATH), "static")

# Absolute path to the directory that shall hold all uploaded files as well as
# files created at runtime. Example: "/home/media/media.lawrence.com/"
UPLOAD_ROOT = join(dirname(PRAKTOMAT_PATH), "PraktomatSupport/")
#SANDBOX_DIR = join('/srv/praktomat/sandbox/', PRAKTOMAT_ID)

# import email settings from file located in Praktomat parent folder
from email_settings import *

DATABASES = {
    'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME':   PRAKTOMAT_ID,
    }
}

ALLOWED_HOSTS = ['*']

# Enabled DEBUG is default
DEBUG = False
#DEBUG = True

# Private key used to sign uploaded solution files in submission confirmation email
PRIVATE_KEY = '/srv/praktomat/mailsign/signer_key.pem'
CERTIFICATE = '/srv/praktomat/mailsign/signer.pem'

# Enable Shibboleth:
SHIB_ENABLED = False

# Set this to False to disable registration via the website, e.g. when Single Sign On is used
REGISTRATION_POSSIBLE = True

SYSADMIN_MOTD_URL = None

# Use a dedicated user to test submissions
USEPRAKTOMATTESTER = False

TEST_MAXLOGSIZE=512
TEST_MAXFILESIZE=512
TEST_TIMEOUT=600
# Rating overview needs one POST parameter per student
# and the default value (1000) might be too low
DATA_UPLOAD_MAX_NUMBER_FIELDS = 2000

# It is recommended to use DOCKER and not a tester account
# for using Docker from https://github.com/nomeata/safe-docker
# Use docker to test submission
# To allow Praktomat the execution of scriptfile  safe-docker  without requiring a password:
# "praktomat	ALL= NOPASSWD: /usr/local/bin/safe-docker"
USESAFEDOCKER = True

# Various extra files and versions
CHECKSTYLEALLJAR = '/srv/praktomat/contrib/checkstyle-8.29-all.jar'
JPLAGJAR = '/srv/praktomat/contrib/jplag-2.12.1-SNAPSHOT-jar-with-dependencies.jar'

# Does Apache use "mod_xsendfile" version 1.0?
# If you use "libapache2-mod-xsendfile", this flag needs to be set to False
MOD_XSENDFILE_V1_0 = False

# Our VM has n cores, so lets try to use them
NUMBER_OF_TASKS_TO_BE_CHECKED_IN_PARALLEL = 10

# Finally load defaults for missing settings.
from . import defaults
defaults.load_defaults(globals())
