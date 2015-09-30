# -*- coding: utf-8 -*-
# Copyright 2014-2015 TIS Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import sys

file_dir = os.path.dirname(__file__)
test_root = os.path.abspath(os.path.join(file_dir, '..', '..'))
pattern_root = os.path.abspath(os.path.join(test_root, '..'))

sys.path.append(os.path.join(pattern_root, 'lib'))
