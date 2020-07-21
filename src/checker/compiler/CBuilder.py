# -*- coding: iso-8859-1 -*-

"""
A C compiler for construction.
"""

from django.conf import settings
from checker.compiler.Builder import Compiler

class CBuilder(Compiler):
    """ A C compiler for construction. """

    # Initialization sets attributes to default values.
    _compiler        = settings.C_BINARY
    _language        = "C"
    #_rx_warnings            = r"^([^ :]*:[^:].*)$"

    def pre_run(self,env):
        return self.compiler()

    def post_run(self,env):
        passed = True
        log = ""
        return [passed,log]

    def connected_flags(self, env):
        return self.search_path() + self.flags()


from checker.admin import CheckerInline, AlwaysChangedModelForm

class CheckerForm(AlwaysChangedModelForm):
    """ override default values for the model fields """
    def __init__(self, **args):
        super(CheckerForm, self).__init__(**args)
        self.fields["_flags"].initial = "-Wall -Wextra"
        #self.fields["_output_flags"].initial = "-o %s"
        self.fields["_libs"].initial = "-c"
        self.fields["_file_pattern"].initial = r"^[a-zA-Z0-9_]*\.[cC]$"

class CBuilderInline(CheckerInline):
    model = CBuilder
    form = CheckerForm
    verbose_name = "C Compiler"
