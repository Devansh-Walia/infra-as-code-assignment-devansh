#!/usr/bin/env python3
"""
Automated tests for Milestone 2 - Functional Infrastructure

This test script verifies that:
1. Valid user registration works
2. Successful user verification returns index.html
3. Failed user verification returns error.html
4. Invalid registration requests are handled properly
5. Invalid verification requests are handled properly
6. Tests are idempotent (can run multiple times)
7. Tests are independent (no dependencies between them)
"""

import json
import requests
import subprocess
import sys
import time
import uuid
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


def generate_test_user_id() -> str:
    """Generate unique test user ID for manual cleanup identification"""
    timestamp = int(time.time())
    unique_id = str(uuid.uuid4())[:8]
    return f"test-user-{timestamp}-{unique_id}"


def test_valid_user_registration():
    """Test 1: Valid user registration"""
    print("🧪 Testing valid user registration...")
    
    api_url = get_terraform_output("api_gateway_url")
    user_id = generate_test_user_id()
    
    print(f"📡 API Gateway URL: {api_url}")
    print(f"👤 Test User ID: {user_id}")
    
    try:
        # Send PUT request to register endpoint
        response = requests.put(f"{api_url}/register?userId={user_id}", timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
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
        
        # Check for success message
        if "message" not in response_data:
            print(f"❌ Response missing 'message' field: {response_data}")
            return False
        
        if "Registered User Successfully" not in response_data["message"]:
            print(f"❌ Response message does not indicate success: {response_data['message']}")
            return False
        
        print("✅ User registration successful!")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False


def test_successful_user_verification():
    """Test 2: Successful user verification (independent test)"""
    print("🧪 Testing successful user verification...")
    
    api_url = get_terraform_output("api_gateway_url")
    user_id = generate_test_user_id()
    
    print(f"📡 API Gateway URL: {api_url}")
    print(f"👤 Test User ID: {user_id}")
    
    try:
        # First register the user
        print("📝 Registering user first...")
        reg_response = requests.put(f"{api_url}/register?userId={user_id}", timeout=30)
        
        if reg_response.status_code != 200:
            print(f"❌ Failed to register user: {reg_response.status_code}")
            return False
        
        # Wait a moment for consistency
        time.sleep(2)
        
        # Now verify the user
        print("🔍 Verifying registered user...")
        response = requests.get(f"{api_url}/?userId={user_id}", timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        print(f"📄 Response Headers: {dict(response.headers)}")
        print(f"📝 Response Body Length: {len(response.text)} characters")
        
        # Check status code
        if response.status_code != 200:
            print(f"❌ Expected status code 200, got {response.status_code}")
            return False
        
        # Check content type
        content_type = response.headers.get('content-type', '')
        if 'text/html' not in content_type:
            print(f"❌ Expected HTML content, got: {content_type}")
            return False
        
        # Check for index.html content
        html_content = response.text
        if "User Verification Successful" not in html_content:
            print(f"❌ Response does not contain success message from index.html")
            return False
        
        if "Welcome!" not in html_content:
            print(f"❌ Response does not contain welcome message from index.html")
            return False
        
        print("✅ User verification successful - received index.html!")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False


def test_failed_user_verification():
    """Test 3: Failed user verification with non-registered user"""
    print("🧪 Testing failed user verification...")
    
    api_url = get_terraform_output("api_gateway_url")
    user_id = f"nonexistent-user-{int(time.time())}"
    
    print(f"📡 API Gateway URL: {api_url}")
    print(f"👤 Non-existent User ID: {user_id}")
    
    try:
        # Try to verify non-existent user
        response = requests.get(f"{api_url}/?userId={user_id}", timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        print(f"📄 Response Headers: {dict(response.headers)}")
        print(f"📝 Response Body Length: {len(response.text)} characters")
        
        # Check status code
        if response.status_code != 200:
            print(f"❌ Expected status code 200, got {response.status_code}")
            return False
        
        # Check content type
        content_type = response.headers.get('content-type', '')
        if 'text/html' not in content_type:
            print(f"❌ Expected HTML content, got: {content_type}")
            return False
        
        # Check for error.html content
        html_content = response.text
        if "User Verification Failed" not in html_content:
            print(f"❌ Response does not contain failure message from error.html")
            return False
        
        if "User not found" not in html_content:
            print(f"❌ Response does not contain 'User not found' message from error.html")
            return False
        
        print("✅ Failed user verification successful - received error.html!")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False


def test_invalid_user_registration():
    """Test 4: Invalid user registration (missing userId parameter)"""
    print("🧪 Testing invalid user registration...")
    
    api_url = get_terraform_output("api_gateway_url")
    
    print(f"📡 API Gateway URL: {api_url}")
    print("📝 Sending registration request without userId parameter")
    
    try:
        # Send PUT request without userId parameter
        response = requests.put(f"{api_url}/register", timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        print(f"📝 Response Body: {response.text}")
        
        # Check that we get an error response
        if response.status_code == 200:
            try:
                response_data = response.json()
                if "message" in response_data and "Error" in response_data["message"]:
                    print("✅ Invalid registration properly handled with error message!")
                    return True
                else:
                    print(f"❌ Expected error message, got: {response_data}")
                    return False
            except json.JSONDecodeError:
                print(f"❌ Response is not valid JSON: {response.text}")
                return False
        else:
            # Non-200 status is also acceptable for invalid requests
            print("✅ Invalid registration properly rejected with non-200 status!")
            return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False


def test_invalid_user_verification():
    """Test 5: Invalid user verification (missing userId parameter)"""
    print("🧪 Testing invalid user verification...")
    
    api_url = get_terraform_output("api_gateway_url")
    
    print(f"📡 API Gateway URL: {api_url}")
    print("📝 Sending verification request without userId parameter")
    
    try:
        # Send GET request without userId parameter
        response = requests.get(f"{api_url}/", timeout=30)
        
        print(f"📊 Response Status: {response.status_code}")
        print(f"📝 Response Body: {response.text}")
        
        # Check that we get an error response
        if response.status_code == 200:
            # Check if it's HTML content (error.html)
            content_type = response.headers.get('content-type', '')
            if 'text/html' in content_type:
                html_content = response.text
                if "User Verification Failed" in html_content or "User not found" in html_content:
                    print("✅ Invalid verification properly handled with error.html!")
                    return True
            
            # Check if it's JSON error
            try:
                response_data = response.json()
                if "message" in response_data and "Error" in response_data["message"]:
                    print("✅ Invalid verification properly handled with error message!")
                    return True
            except json.JSONDecodeError:
                pass
            
            print(f"❌ Expected error response, got: {response.text}")
            return False
        else:
            # Non-200 status is also acceptable for invalid requests
            print("✅ Invalid verification properly rejected with non-200 status!")
            return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")
        return False


def test_idempotency():
    """Test 6: Tests should remain green when running multiple times"""
    print("🧪 Testing idempotency (running key tests twice)...")
    
    # Run registration test twice
    print("🔄 Running registration test - first time")
    result1 = test_valid_user_registration()
    
    print("🔄 Running registration test - second time")
    result2 = test_valid_user_registration()
    
    if result1 and result2:
        print("✅ Registration test is idempotent!")
        return True
    else:
        print("❌ Registration test failed idempotency check")
        return False


def test_independence():
    """Test 7: Tests should be independent (this test verifies by using fresh data)"""
    print("🧪 Testing independence (using completely fresh user data)...")
    
    # This test demonstrates independence by creating a completely new user
    # and verifying the full flow works without depending on previous tests
    api_url = get_terraform_output("api_gateway_url")
    user_id = generate_test_user_id()
    
    print(f"👤 Fresh Test User ID: {user_id}")
    
    try:
        # Register fresh user
        reg_response = requests.put(f"{api_url}/register?userId={user_id}", timeout=30)
        if reg_response.status_code != 200:
            print(f"❌ Failed to register fresh user: {reg_response.status_code}")
            return False
        
        # Wait for consistency
        time.sleep(2)
        
        # Verify fresh user
        verify_response = requests.get(f"{api_url}/?userId={user_id}", timeout=30)
        if verify_response.status_code != 200:
            print(f"❌ Failed to verify fresh user: {verify_response.status_code}")
            return False
        
        # Check for success content
        if "User Verification Successful" not in verify_response.text:
            print("❌ Fresh user verification did not return success page")
            return False
        
        print("✅ Test independence verified - fresh user flow works!")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Independence test failed: {e}")
        return False


def main():
    """Run all Milestone 2 tests"""
    print("🚀 Starting Milestone 2 Tests")
    print("=" * 60)
    
    tests = [
        ("Valid User Registration", test_valid_user_registration),
        ("Successful User Verification", test_successful_user_verification),
        ("Failed User Verification", test_failed_user_verification),
        ("Invalid User Registration", test_invalid_user_registration),
        ("Invalid User Verification", test_invalid_user_verification),
        ("Test Idempotency", test_idempotency),
        ("Test Independence", test_independence),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n📋 Running: {test_name}")
        print("-" * 40)
        
        if test_func():
            passed += 1
            print(f"✅ {test_name}: PASSED")
        else:
            print(f"❌ {test_name}: FAILED")
    
    print("\n" + "=" * 60)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Milestone 2 is ready for submission.")
        print("\n📝 Note: Test users created with IDs starting with 'test-user-' can be manually cleaned up from DynamoDB if needed.")
        sys.exit(0)
    else:
        print("💥 Some tests failed. Please check the infrastructure and Lambda functions.")
        sys.exit(1)


if __name__ == "__main__":
    main()
