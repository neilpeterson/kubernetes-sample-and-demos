package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

type target struct {
	APIVersion string `json:"apiVersion"`
	Kind       string `json:"kind"`
	Name       string `json:"name"`
}

type metadata struct {
	Name string `json:"name"`
}

type podUpdate struct {
	APIVersion string   `json:"apiVersion"`
	Kind       string   `json:"kind"`
	Metadata   metadata `json:"metadata"`
	Target     target   `json:"target"`
}

func main() {

	// Initilization information - package rest
	var (
		config *rest.Config
		err    error
	)

	kubeconfig := os.Getenv("KUBECONFIG")

	// Authentication / connection object - package tools/clientcmd
	config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating client: %v", err)
		os.Exit(1)
	}

	// Kubernetes client - package kubernetes
	clientset := kubernetes.NewForConfigOrDie(config)

	pu := &podUpdate{
		APIVersion: "v1",
		Kind:       "Binding",
		Metadata: metadata{
			Name: "aci-helloworld-1927304711-tz028",
		},
		Target: target{
			APIVersion: "v1",
			Kind:       "Node",
			Name:       "aks-nodepool1-42032720-1",
		},
	}

	body, err := json.Marshal(pu)
	if err != nil {
		log.Println(err)
	}

	err = clientset.RESTClient().Post().RequestURI("http://kubernetes/api/v1/namespaces/default/pods/aks-nodepool1-42032720-1/binding").Body(body).Do().Error()
	if err != nil {
		fmt.Println(err)
	}
}
