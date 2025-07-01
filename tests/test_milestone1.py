#!/usr/bin/env python3
"""
Automated tests for Milestone 1 - Infrastructure Foundation

This test script verifies that:
1. The API Gateway URL endpoint returns "Hello world" response
"""

import json
import requests
import subprocess
import sys
import time
from typing import Dict, Any


def get_terraform_output(output_name: str) -> str:
    """Get terraform output value"""
    try:
        result = subprocess.run(
            ["terraform", "output", "-raw", output_name],
            cwd="terraform",
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error getting terraform output '{output_name}': {e}")
        print(f"stderr: {e.stderr}")
        sys.exit(1)


def test_api_gateway_hello_world():
    """Test that API Gateway returns 'Hello world' from Lambda function"""
    print("🧪 Testing API Gateway Hello World endpoint...")
    
    # Get API Gateway URL from terraform output
    api_url = get_terraform_output("api_gateway_url")
    if not api_url:
        print("❌ Failed to get API Gateway URL from terraform output")
        return False
    
    print(f"📡 API Gateway URL: {api_url}")
    
    try:
        # Make GET request to root endpoint
        response = requests.get(f"{api_url}/", timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        print(f"📄 Response Headers: {dict(response.headers)}")
        print(f"📝 Response Body: {response.text}")
        
        # Check status code
        if response.status_code != 200:
            print(f"❌ Expected status code 200, got {response.status_code}")
            return False
        
        # Parse JSON response
        try:
            response_data = response.json()
        except json.JSONDecodeError:
            print(f"❌ Response is not valid JSON: {response.text}")
            return False
        
        # Check for "Hello world" message
        if "message" not in response_data:
            print(f"❌ Response missing 'message' field: {response_data}")
            return False
        
        if "Hello world" not in response_data["message"]:
            print(f"❌ Response message does not contain 'Hello world': {response_data['message']}")
            return False
        
        print("✅ API Gateway successfully returned 'Hello world' response!")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False


def test_lambda_function_exists():
    """Test that Lambda function exists and has correct name"""
    print("🧪 Testing Lambda function existence...")
    
    try:
        lambda_name = get_terraform_output("lambda_function_name")
        lambda_arn = get_terraform_output("lambda_function_arn")
        
        print(f"🔧 Lambda Function Name: {lambda_name}")
        print(f"🔧 Lambda Function ARN: {lambda_arn}")
        
        if not lambda_name or not lambda_arn:
            print("❌ Lambda function outputs are empty")
            return False
        
        if "hello-world" not in lambda_name:
            print(f"❌ Lambda function name should contain 'hello-world': {lambda_name}")
            return False
        
        print("✅ Lambda function exists with correct naming!")
        return True
        
    except Exception as e:
        print(f"❌ Error checking Lambda function: {e}")
        return False


def main():
    """Run all Milestone 1 tests"""
    print("🚀 Starting Milestone 1 Tests")
    print("=" * 50)
    
    tests = [
        ("Lambda Function Existence", test_lambda_function_exists),
        ("API Gateway Hello World", test_api_gateway_hello_world),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n📋 Running: {test_name}")
        print("-" * 30)
        
        if test_func():
            passed += 1
            print(f"✅ {test_name}: PASSED")
        else:
            print(f"❌ {test_name}: FAILED")
    
    print("\n" + "=" * 50)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Milestone 1 is ready for submission.")
        sys.exit(0)
    else:
        print("💥 Some tests failed. Please check the infrastructure.")
        sys.exit(1)


if __name__ == "__main__":
    main()
