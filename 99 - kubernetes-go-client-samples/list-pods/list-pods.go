package main

import (
	"fmt"
	"os"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

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

	// Get pods -- package metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	pods, _ := clientset.CoreV1().Pods("default").List(metav1.ListOptions{})
	for _, p := range pods.Items {
		fmt.Println(p.GetName())
	}
}
