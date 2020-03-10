# Settings for deployment

# These settings are KIT-specific and derive some parts of the settings
# from the directory name.
#
# If you are not deploying on praktomat.cs.kit.edu you need to rewrite this file.

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
		SITE_NAME = 'Softwareprojekt EKT '
	else:
		SITE_NAME = 'Programmieren '

	year = int(match.group('year'))
	if match.group('semester') == "WS":
		SITE_NAME += "Wintersemester %d/%d" % (year, year+1)
	else:
		SITE_NAME += "Sommersemester %d" % year

else:
    raise NotImplementedError("Autoconfig for PRAKTOMAT_ID %s not possible", PRAKTOMAT_ID)

# The name that will be displayed on top of the page and in emails.
#SITE_NAME = 'Praktomat der Frankfurt University of Applied Sciences'

# The URL where this site is reachable. 'http://localhost:8000/' in case of the
# development server.
BASE_HOST = 'https://praktomat.cs.kit.edu'
BASE_PATH = '/' + PRAKTOMAT_ID + '/'

ALLOWED_HOSTS = [ 'praktomat.cs.kit.edu', ]

# URL to use when referring to static files.
STATIC_URL = BASE_PATH + 'static/'

STATIC_ROOT = join(dirname(PRAKTOMAT_PATH), "static")

TEST_MAXLOGSIZE=512

TEST_MAXFILESIZE=512

TEST_TIMEOUT=180

if "cram" in PRAKTOMAT_ID:
  TEST_TIMEOUT=600
  TEST_MAXMEM=200

if "birap" in PRAKTOMAT_ID:
  TEST_TIMEOUT=600

if "tba" in PRAKTOMAT_ID:
  TEST_TIMEOUT=600

if "Programmieren" in SITE_NAME:
  # Rating overview needs one POST parameter per student
  # and the default value (1000) might be too low
  DATA_UPLOAD_MAX_NUMBER_FIELDS = 2000

# Absolute path to the directory that shall hold all uploaded files as well as
# files created at runtime.

# Example: "/home/media/media.lawrence.com/"
UPLOAD_ROOT = join(dirname(PRAKTOMAT_PATH), "PraktomatSupport/")
#SANDBOX_DIR = join('/home/praktomat/sandbox/', PRAKTOMAT_ID)

if MIRROR:
    SANDBOX_DIR = join('/srv/praktomat/sandbox_Mirror/', PRAKTOMAT_ID)
else:
    SANDBOX_DIR = join('/srv/praktomat/sandbox/', PRAKTOMAT_ID)

ADMINS = [
  ('Praktomat', 'praktomat@ipd.info.uni-karlsruhe.de')
]

SERVER_EMAIL = 'praktomat@i44vm3.info.uni-karlsruhe.de'


if MIRROR:
    EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
    EMAIL_FILE_PATH = join(UPLOAD_ROOT, "sent-mails")
else:
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = "localhost"
    EMAIL_PORT = 25

DEFAULT_FROM_EMAIL = "praktomat@ipd.info.uni-karlsruhe.de"

DEBUG = MIRROR

DATABASES = {
    'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME':   PRAKTOMAT_ID,
    }
}

# Private key used to sign uploded solution files in submission confirmation email
PRIVATE_KEY = '/srv/praktomat/mailsign/signer_key.pem'
CERTIFICATE = '/srv/praktomat/mailsign/signer.pem'
Private_KEY = None

# Enable Shibboleth:
SHIB_ENABLED = FALSE
REGISTRATION_POSSIBLE = False

SYSADMIN_MOTD_URL = None

# Use a dedicated user to test submissions
USEPRAKTOMATTESTER = False

# It is recommended to use DOCKER and not a tester account
# for using Docker from https://github.com/nomeata/safe-docker
# Use docker to test submission
# To allow Praktomat the execution of scriptfile  safe-docker  without requiring a password:
# "praktomat	ALL= NOPASSWD: /usr/local/bin/safe-docker"
USESAFEDOCKER = True

# Various extra files and versions
CHECKSTYLEALLJAR = '/srv/praktomat/contrib/checkstyle-5.7-all.jar'
JPLAGJAR = '/srv/praktomat/contrib/jplag.jar'
#JAVA_BINARY = 'javac-sun-1.7'
#JVM = 'java-sun-1.7'

# Our VM has 4 cores, so lets try to use them
NUMBER_OF_TASKS_TO_BE_CHECKED_IN_PARALLEL = 6
# But not with Isabelle, which is memory bound
if match.group('tba') is not None:
    NUMBER_OF_TASKS_TO_BE_CHECKED_IN_PARALLEL = 1

# Finally load defaults for missing settings.
from . import defaults
defaults.load_defaults(globals())
