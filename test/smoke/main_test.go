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
	"math/rand"
	"time"
	"path/filepath"
	
	"github.com/DATA-DOG/godog"
	
	"github.com/kiegroup/kogito-cloud-operator/pkg/logger"
)

var log = logger.GetLogger("smoke_tests")

type Data struct {
	Namespace string
	StartTime time.Time
}

func (data *Data) setUp(interface{}) {
	data.StartTime = time.Now()
	
	// Define and create namespace
	rand.Seed(time.Now().UnixNano())
	ns := "cucumber-" + randSeq(4)
	if err := CreateNamespace(ns); err != nil { panic(err) }
	
	data.Namespace = ns
}

func (data *Data) tearDown(fn interface{}, err error) {
	if e := DeleteNamespace(data.Namespace); e != nil { panic(e) }
	
	endTime := time.Now()
	duration := endTime.Sub(data.StartTime)
	log.Infof("Scenario duration = %s", duration.String())
	
	if(err != nil){
		panic(err)
	}
}

// Operator steps
func (data *Data) kogitoOperatorIsDeployed() error {
	// if operator not available, then install via yaml files
	if exists, err := IsOperatorRunning(data.Namespace); err != nil {
		return fmt.Errorf("Error while trying to retrieve the operator: %v ", err)
	} else if !exists {
		if err := DeployOperatorFromYaml(data.Namespace); err != nil {
			return fmt.Errorf("Error while deploying operator: %v", err)
		}
		
		if err := WaitForOperatorRunning(data.Namespace); err != nil {
			return fmt.Errorf("Error while checking operator running: %v", err)
		}
	}
	
	return nil
}

func (data *Data) kogitoOperatorIsDeployedWithDependencies() error {
	// TODO
	return nil
}

// Deploy service steps
func (data *Data) deployQuarkusExampleServiceWithNative(contextDir, native string) error {
	return DeployQuarkusExample(data.Namespace, filepath.Base(contextDir), contextDir, native == "enabled", false)
}

func (data *Data) deployQuarkusExampleServiceWithPersistenceAndNative(contextDir, native string) error {
	return DeployQuarkusExample(data.Namespace, filepath.Base(contextDir), contextDir, native == "enabled", true)
}

func (data *Data) deploySpringBootExampleService(contextDir string) error {
	return DeploySpringBootExample(data.Namespace, filepath.Base(contextDir), contextDir, false)
}

func (data *Data) deploySpringBootExampleServiceWithPersistence(contextDir string) error {
	return DeploySpringBootExample(data.Namespace, filepath.Base(contextDir), contextDir, true)
}

// Build steps
func (data *Data) buildIsCompleteAfterMinutes(buildName string, timeoutInMin int) error {
	return WaitForBuildComplete(data.Namespace, buildName, timeoutInMin)
}

// DeploymentConfig steps
func (data *Data) deploymentConfigHasPodRunningWithinMinutes(dcName string, podNb, timeoutInMin int) error {
	return WaitForDeploymentConfigRunning(data.Namespace, dcName, podNb, timeoutInMin)
}

// HTTP call steps
func (data *Data) httpRequestWithPathOnServiceIsSuccessfulWithinMinutes(httpMethod, path, serviceName string, timeoutInMin int) error {
	if err := WaitForRoute(data.Namespace, serviceName, 2); err != nil {
		return fmt.Errorf("Route %s does not exist in namespace %s after %d minutes: %v", serviceName, data.Namespace, timeoutInMin, err)
	}
	routeUri, err := GetRouteUri(data.Namespace, serviceName)
	if err != nil { 
		return fmt.Errorf("Error retrieving URI for route %s in namespace %s: %v", serviceName, data.Namespace, err) 
	} else if routeUri == "" { 
		return fmt.Errorf("No URI found for route name %s in namespace %s: %v", serviceName, data.Namespace, err) 
	}
	
	log.Infof("Got route %s\n", routeUri)
	return waitForHttpRequest(httpMethod, routeUri, path, nil, timeoutInMin)
}

func (data *Data) callHttpRequestOnServiceWithPathAndBody(httpMethod, serviceName, path, bodyFormat, bodyContent string){
	// TODO
	return nil
}

func FeatureContext(s *godog.Suite) {
	data := &Data{}
	// Create kube client
	initKubeClient()
	
	s.BeforeScenario(data.setUp)
	s.AfterScenario(data.tearDown)
	
	// Operator steps
	s.Step(`^Kogito Operator is deployed$`, data.kogitoOperatorIsDeployed)
	s.Step(`^Kogito Operator is deployed with dependencies$`, data.kogitoOperatorIsDeployed)
	
	// Deploy steps
	s.Step(`^Deploy quarkus example service "([^"]*)" with native "([^"]*)"$`, data.deployQuarkusExampleServiceWithNative)
	s.Step(`^Deploy quarkus example service "([^"]*)" with persistence enabled and native "([^"]*)"$`, data.deployQuarkusExampleServiceWithNative)
	s.Step(`^Deploy spring boot example service "([^"]*)"$`, data.deploySpringBootExampleService)
	
	// Build steps
	s.Step(`^Build "([^"]*)" is complete after (\d+) minutes$`, data.buildIsCompleteAfterMinutes)
	
	// DeploymentConfig steps
	s.Step(`^DeploymentConfig "([^"]*)" has (\d+) pod running within (\d+) minutes$`, data.deploymentConfigHasPodRunningWithinMinutes)
	
	// HTTP call steps
	s.Step(`^Call HTTP "([^"]*)" request with path "([^"]*)" on service "([^"]*)" is successful within (\d+) minutes$`, data.httpRequestWithPathOnServiceIsSuccessfulWithinMinutes)
}

