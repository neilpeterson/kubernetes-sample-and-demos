// This sample will update the scheduler in pod spec / template of a replica set.

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

	// Initilization information
	var (
		config *rest.Config
		err    error
	)

	kubeconfig := os.Getenv("KUBECONFIG")

	// Authentication
	config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error creating client: %v", err)
		os.Exit(1)
	}

	// Kubernetes client
	clientset := kubernetes.NewForConfigOrDie(config)

	// Get pod
	pod, _ := clientset.CoreV1().Pods("default").Get("aci-helloworld-1927304711-pps5k", metav1.GetOptions{})

	// Do whatever...
	fmt.Println(pod.Spec.SchedulerName)
}
