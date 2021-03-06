
#
# Cookbook Name:: bsdznc
# Resource:: default
#
# Copyright 2015 Evan Sosenko
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

=begin
#<
@action create create the znc server.
@action start start the znc server.
@action stop stop the znc server.
@action restart restart the znc server.
@action destroy stop and destroy the znc server.
@action nothing do nothing.
#>
=end

default_action :create
actions :create, :start, :stop, :restart, :destroy
