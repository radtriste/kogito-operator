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
	"time"
	
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	corev1 "k8s.io/api/core/v1"
	coreapps "k8s.io/api/apps/v1"
	rbac "k8s.io/api/rbac/v1"
	apiextensionsv1beta1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1beta1"
	
	"github.com/kiegroup/kogito-cloud-operator/pkg/client/kubernetes"
	infra "github.com/kiegroup/kogito-cloud-operator/pkg/infrastructure"
	"github.com/kiegroup/kogito-cloud-operator/pkg/util"
	"github.com/kiegroup/kogito-cloud-operator/version"
)

const (
	defaultOperatorImageName="quay.io/kiegroup/kogito-cloud-operator"
	defaultOperatorDeployUri = "https://raw.githubusercontent.com/kiegroup/kogito-cloud-operator/master/deploy/"
	
	kogitoCrdGroupName = "app.kiegroup.org";
    kogitoAppCrdName = "kogitoapps";
    kogitoInfraCrdName = "kogitoinfras";
    kogitoDataIndexCrdName = "kogitodataindices"
)

var (
	defaultOperatorImageTag = version.Version
)

func DeployOperatorFromYaml(namespace string) error{
	// Create crds files if needed
	if err := deployCrdIfNeeded(kogitoAppCrdName); err != nil { return err }
	if err := deployCrdIfNeeded(kogitoInfraCrdName); err != nil { return err }
	if err := deployCrdIfNeeded(kogitoDataIndexCrdName); err != nil { return err }
	
	var deployUri = getOperatorDeployUri()
	log.Infof("Deploy Operator from yaml files in %s", deployUri)
	
	loadResource(namespace, deployUri + "service_account.yaml",  &corev1.ServiceAccount{}, nil)
	loadResource(namespace, deployUri + "role.yaml",  &rbac.Role{}, nil)
	loadResource(namespace, deployUri + "role_binding.yaml",  &rbac.RoleBinding{}, nil)
	loadResource(namespace, deployUri + "operator.yaml",  &coreapps.Deployment{}, func(object interface{}) {
			log.Debugf("Using operator image %s", getOperatorImageNameAndTag())
			object.(*coreapps.Deployment).Spec.Template.Spec.Containers[0].Image = getOperatorImageNameAndTag()
	})
	
	return nil
}

func IsOperatorRunning(namespace string) (bool,error) {
	exists, err := infra.CheckKogitoOperatorExists(kubeClient, namespace)
	if err != nil {
		if exists {
			return false, nil
		}
		return false, err
	}
	return exists, nil
}

func WaitForOperatorRunning(namespace string) error {
	return waitFor("operator running", time.Minute * 2, func() (bool, error){ 
			return IsOperatorRunning(namespace)
	})
}

func deployCrdIfNeeded(crdName string) error {
	crdFullName := buildCrdFullName(crdName)
	crdEntity := &apiextensionsv1beta1.CustomResourceDefinition{
		ObjectMeta : metav1.ObjectMeta {
			Name: crdFullName,
		},
	}
	if exists, err := kubernetes.ResourceC(kubeClient).Fetch(crdEntity); err != nil {
		return fmt.Errorf("Error while trying to look for Kogito Operator installation: %v", err)
	} else if !exists {
		crdUri := getOperatorDeployUri() + "crds/" + buildCrdFilename(crdName)
		log.Infof("deployCrd %s", crdUri)
		return loadResource("", crdUri, &apiextensionsv1beta1.CustomResourceDefinition{}, nil)	 
	}
	
	return nil
}

func buildCrdFullName(crdName string) string {
    return crdName + "." + kogitoCrdGroupName;
}

func buildCrdFilename(crdName string) string {
    return kogitoCrdGroupName + "_" + crdName + "_crd.yaml";
}

func getOperatorDeployUri() string {
	return util.GetOSEnv("OPERATOR_DEPLOY_FOLDER", defaultOperatorDeployUri)
}
func getOperatorImageName() string {
	return util.GetOSEnv("OPERATOR_IMAGE_NAME", defaultOperatorImageName)
}
func getOperatorImageTag() string {
	return util.GetOSEnv("OPERATOR_IMAGE_TAG", defaultOperatorImageTag)
}
func getOperatorImageNameAndTag() string {
	return fmt.Sprintf("%s:%s", getOperatorImageName(), getOperatorImageTag())
}