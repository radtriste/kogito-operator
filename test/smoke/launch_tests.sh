#!/bin/bash
# Copyright 2019 Red Hat, Inc. and/or its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

wip=$1

export MAVEN_MIRROR_URL="http://bxms-qe.rhev-ci-vms.eng.rdu2.redhat.com:8081/nexus/content/groups/public"

export OPERATOR_DEPLOY_FOLDER="/home/tradisso/projects/kogito/kogito-cloud-operator/deploy/"
export OPERATOR_IMAGE_NAME="quay.io/tradisso/kogito-cloud-operator"
export OPERATOR_IMAGE_TAG="0.7.0-rc1"

godog -c 2 --random -f progress $wip
