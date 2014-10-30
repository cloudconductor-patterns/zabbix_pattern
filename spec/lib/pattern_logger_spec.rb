# -*- coding: utf-8 -*-
# Copyright 2014 TIS Inc.
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
require_relative '../../lib/pattern_logger.rb'

describe CloudConductorPattern::PatternLogger do
  describe '#logger' do
    it 'creates and returns the logger instance' do
      dummy_logger = double(:logger)
      allow(Logger).to receive(:new).with('testlog.log').and_return(dummy_logger)
      expect(dummy_logger).to receive('formatter=').with(instance_of(Proc))
      logger = CloudConductorPattern::PatternLogger.logger('testlog.log')
      expect(logger).not_to be_nil
    end
  end
end
