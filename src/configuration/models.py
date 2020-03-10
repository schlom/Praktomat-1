from django.db import models
from datetime import date
from django.utils.translation import ugettext_lazy as _

class Settings(models.Model):
    """ Singleton object containing site wide settings configurable by the trainer. """

    class Meta:
        # Django admin adds an 's' to the class name; prevent SettingSS
        verbose_name = _('Setting')
        verbose_name_plural = _('Settings')

    email_validation_regex = \
            models.CharField(
		        verbose_name=_('Email validation regex'),
                max_length=200,
                blank=True,
                default=".*@(stud.)?fra-uas.de",
                help_text="Regular expression used to check the email domain of registering users."
            )

    mat_number_validation_regex = \
            models.CharField(
		        verbose_name=_('Mat number validation regex'),
                max_length=200,
                blank=True,
                default="\d{5,7}",
                help_text=_("Regular expression used to check the student number.")
            )

    new_users_via_sso = \
            models.BooleanField(
		        verbose_name=_('New user via sso'),
                default=True,
                help_text=_("If enabled, users previously unknown to the Praktomat can register via single sign on (eg. Shibboleth).")
            )

    deny_registration_from = \
            models.DateTimeField(
		        verbose_name=_('Deny registration from'),
                default=date(2222, 1, 1),
                help_text=_("After this date, registration won't be possible.")
            )

    acount_activation_days = \
            models.IntegerField(
		        verbose_name=_('Account activation days'),
                default=10,
                help_text=_("Days until the user has time to activate his account with the link sent in the registration email.")
            )

    account_manual_validation = \
            models.BooleanField(
		        verbose_name=_('Account manual validation'),
                default=False,
                help_text=_("If enabled, registrations via the website must be manually validated by a trainer.")
            )

    accept_all_solutions = \
            models.BooleanField(
                verbose_name=_('Accept all solutions'),
                default=False,
                help_text=_("If enabled, solutions can become the final soution even if not all required checkers are passed.")
            )

    anonymous_attestation = \
            models.BooleanField(
		        verbose_name=_('Anonymous attestation'),
                default=False,
                help_text=_("If enabled, the tutor can't see the name of the user who submitted the solution.")
            )

    final_grades_published = \
            models.BooleanField(
		        verbose_name=_('Finale grades published'),
                default=False,
                help_text=_("If enabled, all users can see their final grades.")
            )

    SUM = 'SUM'
    AVERAGE = 'AVG'

    ARITHMETIC_CHOICES = (
        (SUM, _('Sum')),
        (AVERAGE, _('Average')),
    )

    final_grades_arithmetic_option = \
            models.CharField(
		        verbose_name=_('Final grades arithmetic option'),
                max_length=3,
                choices=ARITHMETIC_CHOICES,
                default=SUM,
            )

    WITH_PLAGIARISM = 'WP'
    NO_PLAGIARISM = 'NP'

    PLAGIARISM_CHOICES = (
        (NO_PLAGIARISM, _('Without')),
        (WITH_PLAGIARISM, _('Including')),
    )

    final_grades_plagiarism_option = \
            models.CharField(
		        verbose_name=_('Final grades plagiarism option'),
                max_length=2,
                choices=PLAGIARISM_CHOICES,
                default=NO_PLAGIARISM,
            )

    invisible_attestor = \
            models.BooleanField(
		        verbose_name=_('Invisible attestor'),
                default=False,
                help_text=_("If enabled, a user will not learn which tutor wrote attestations to his solutions. In particular, tutors will not be named in attestation emails.")
            )

    attestation_reply_to = \
            models.EmailField(
		        verbose_name=_('Attestation Reply-To'),
                blank=True,
                help_text=_("Additional Reply-To: address to be set for attestation emails.")
            )

    attestation_allow_run_checkers = \
            models.BooleanField(
		        verbose_name=_('Attestation allow run checkers'),
                default=False,
                help_text=_("If enabled, tutors can re-run all checkers for solutions they attest. Can be used to re-run checks that failed due to problems unrelated to the solution (e.g.: time-outs because of high server load), but needs to be used with care, since it may change the results from what the student saw when he submitted his solution.")
            )

    jplag_setting = \
            models.CharField(
                max_length=200,
                default='Java',
                help_text=_("Default settings for jPlag")
            )


class Chunk(models.Model):

    class Meta:
        verbose_name = _('Chunk')
        verbose_name_plural = _('Chunks')

    """ A Chunk is a piece of content associated with a unique key that can be inserted into any template with the use of a special template tag """
    settings = models.ForeignKey(
            Settings,
            default=1,
            help_text=_("Makes it easy to display chunks as inlines in Settings."),
            on_delete=models.CASCADE
        )

    key = \
            models.CharField(
                help_text=_("A unique name for this chunk of content"),
                blank=False,
                max_length=255,
                unique=True,
                editable=False
            )

    content = models.TextField(blank=True, verbose_name=_('Content'))

    def __str__(self):
        return "%s" % (self.key,)
