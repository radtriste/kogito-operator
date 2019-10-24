// Copyright 2019 Red Hat, Inc. and/or its affiliates
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	
	"github.com/kiegroup/kogito-cloud-operator/pkg/apis/app/v1alpha1"
	"github.com/kiegroup/kogito-cloud-operator/pkg/client/kubernetes"
	"github.com/kiegroup/kogito-cloud-operator/pkg/util"
)

const (
	kogitoExamplesURI = "https://github.com/kiegroup/kogito-examples"
)

func DeployQuarkusExample(namespace, appName, contextDir string, native, persistence bool) error{
	log.Infof("Deploy quarkus example %s with name %s, native %v and persistence %v", contextDir, appName, native, persistence)
	return DeployExample(namespace, appName, contextDir, "quarkus", native, persistence)
}

func DeploySpringBootExample(namespace, appName, contextDir string, persistence bool) error{
	log.Infof("Deploy spring boot example %s with name %s and persistence %v", contextDir, appName, persistence)
	return DeployExample(namespace, appName, contextDir, "springboot", false, persistence)
}

func DeployExample(namespace, appName, contextDir, runtime string, native, persistence bool) error {
	gitProjectURI := kogitoExamplesURI
	
	kogitoApp := getKogitoAppStub(namespace, appName)
	if runtime == "quarkus" {
		kogitoApp.Spec.Runtime = v1alpha1.QuarkusRuntimeType
	} else if runtime == "springboot" {
		kogitoApp.Spec.Runtime = v1alpha1.SpringbootRuntimeType
	} 
	kogitoApp.Spec.Build.Native = native
	kogitoApp.Spec.Build.GitSource.URI = &gitProjectURI
	kogitoApp.Spec.Build.GitSource.ContextDir = contextDir
	
	if persistence {
		appendNewEnvToKogitoAppBuild(kogitoApp, "MAVEN_ARGS_APPEND", "-Ppersistence")
	}
	
	// If "KOGITO_BUILD_IMAGE_STREAM_[TAG|NAME|NAMESPACE]" is defined, it is taken into account
	// If not defined then search for specific s2i and runtime tags
	// If none, let the operator manage
	kogitoApp.Spec.Build.ImageS2I.ImageStreamTag = util.GetOSEnv("KOGITO_BUILD_IMAGE_STREAM_TAG", util.GetOSEnv("KOGITO_BUILD_S2I_IMAGE_STREAM_TAG", ""))
	kogitoApp.Spec.Build.ImageS2I.ImageStreamName = util.GetOSEnv("KOGITO_BUILD_IMAGE_STREAM_NAME", util.GetOSEnv("KOGITO_BUILD_S2I_IMAGE_STREAM_NAME", ""))
	kogitoApp.Spec.Build.ImageS2I.ImageStreamNamespace = util.GetOSEnv("KOGITO_BUILD_IMAGE_STREAM_NAMESPACE", util.GetOSEnv("KOGITO_BUILD_S2I_IMAGE_STREAM_NAMESPACE", ""))
	kogitoApp.Spec.Build.ImageRuntime.ImageStreamTag = util.GetOSEnv("KOGITO_BUILD_IMAGE_STREAM_TAG", util.GetOSEnv("KOGITO_BUILD_RUNTIME_IMAGE_STREAM_TAG", ""))
	kogitoApp.Spec.Build.ImageRuntime.ImageStreamName = util.GetOSEnv("KOGITO_BUILD_IMAGE_STREAM_NAME", util.GetOSEnv("KOGITO_BUILD_RUNTIME_IMAGE_STREAM_NAME", ""))
	kogitoApp.Spec.Build.ImageRuntime.ImageStreamNamespace = util.GetOSEnv("KOGITO_BUILD_IMAGE_STREAM_NAMESPACE", util.GetOSEnv("KOGITO_BUILD_RUNTIME_IMAGE_STREAM_NAMESPACE", ""))
	
	if _, err := kubernetes.ResourceC(kubeClient).CreateIfNotExists(kogitoApp); err != nil {
		return fmt.Errorf("Error creating example service %s: %v", appName, err)
	}
	return nil
}


func getKogitoAppStub(namespace, appName string) *v1alpha1.KogitoApp {
	kogitoApp := &v1alpha1.KogitoApp{
		ObjectMeta: metav1.ObjectMeta{
			Name:      appName,
			Namespace: namespace,
		},
		Status: v1alpha1.KogitoAppStatus{
			Conditions:  []v1alpha1.Condition{},
			Deployments: v1alpha1.Deployments{},
		},
		Spec: v1alpha1.KogitoAppSpec{
			Build: &v1alpha1.KogitoAppBuildObject{
				Env: []v1alpha1.Env{},
				GitSource: &v1alpha1.GitSource{},
			},
		},
	}
	
	if mavenMirrorUrl := util.GetOSEnv("MAVEN_MIRROR_URL", ""); mavenMirrorUrl != "" {
		appendNewEnvToKogitoAppBuild(kogitoApp, "MAVEN_MIRROR_URL", util.GetOSEnv("MAVEN_MIRROR_URL", ""))
	}

	return kogitoApp
}

func appendNewEnvToKogitoAppBuild(kogitoApp *v1alpha1.KogitoApp, name, value string){
	env := v1alpha1.Env{
		Name:  name,
		Value: value,
	}
	kogitoApp.Spec.Build.Env = append(kogitoApp.Spec.Build.Env, env)
}

