#!/usr/bin/env python

import CreateVM

vm = CreateVM.CreateVM()

vm.change_conf('use_snd', 'Bla');
vm.show_summary();
