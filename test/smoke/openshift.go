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
	
	ocapps "github.com/openshift/api/apps/v1"
	buildv1 "github.com/openshift/api/build/v1"
	routev1 "github.com/openshift/api/route/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/types"
	
	"github.com/kiegroup/kogito-cloud-operator/pkg/client/kubernetes"
	"github.com/kiegroup/kogito-cloud-operator/pkg/client/openshift"
)

func WaitForBuildComplete(namespace, buildName string, timeoutInMin int) error {
	return waitFor(fmt.Sprintf("build %s complete", buildName), time.Duration(timeoutInMin) * time.Minute, func() (bool, error){
			bc := buildv1.BuildConfig{
				ObjectMeta: metav1.ObjectMeta{
					Name:      buildName,
					Namespace: namespace,
				},
			}
			builds, err := openshift.BuildConfigC(kubeClient).GetBuildsStatus(&bc, fmt.Sprintf("%s=%s", "buildconfig", buildName))

			if err != nil {
				return false, fmt.Errorf("Error while fetching buildconfig %s: %v", buildName, err)
			} else if builds == nil || len(builds.Complete) < 1 {
				return false, nil
			}
			
			return true, nil
	})
}

func WaitForDeploymentConfigRunning(namespace, dcName string, podNb int, timeoutInMin int) error {
	return waitFor(fmt.Sprintf("deploymentconfig %s running", dcName), time.Duration(timeoutInMin) * time.Minute, func() (bool, error){
			dc := &ocapps.DeploymentConfig {}
			if exists, err := kubernetes.ResourceC(kubeClient).FetchWithKey(types.NamespacedName{Name: dcName, Namespace: namespace}, dc); err != nil && !errors.IsNotFound(err) {
				return false, fmt.Errorf("Error while trying to look for DeploymentConfig %s: %v ", dcName, err)	
			} else if errors.IsNotFound(err) || !exists {
				return false, nil
			}
			
			log.Debugf("Deployment config has %d available replicas\n", dc.Status.AvailableReplicas)
			return dc.Status.AvailableReplicas == int32(podNb), nil
	})
}

func WaitForRoute(namespace, routeName string, timeoutInMin int) error {
	return waitFor(fmt.Sprintf("route %s available", routeName), time.Duration(timeoutInMin) * time.Minute, func() (bool, error){
			route, err := GetRoute(namespace, routeName)
			if err != nil || route == nil {
				return false, err
			}	
			
			return true, nil 
	})
}

func GetRoute(namespace, routeName string) (*routev1.Route, error){
	route := &routev1.Route{}
	if exists, err :=
		kubernetes.ResourceC(kubeClient).FetchWithKey(types.NamespacedName{Name: routeName, Namespace: namespace}, route); err != nil {
		return nil, err
	} else if !exists {
		return nil, nil
	} else {
		return route, nil
	}
}

func GetRouteUri(namespace, routeName string) (string, error) {
	route, err := GetRoute(namespace, routeName)
	if err != nil || route == nil {
		return "", err
	}
	host := route.Spec.Host
	
	protocol := "http"
	port := "80"
	if route.Spec.TLS != nil {
		protocol = "https"
		port = "443"
	}
	
	uri := protocol + "://" + host + ":" + port
	return uri, nil 
}