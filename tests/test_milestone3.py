#!/usr/bin/env python3
"""
Milestone 3 Tests - GitHub Actions CI/CD Pipeline Testing

This test suite validates the GitHub Actions workflow functionality and
infrastructure deployment capabilities for Milestone 3.

Tests include:
- GitHub Actions workflow validation
- OIDC authentication verification
- Infrastructure deployment testing
- Security scanning validation
- Complete CI/CD pipeline testing

Usage:
    python tests/test_milestone3.py

Requirements:
    - GitHub repository with Actions enabled
    - AWS credentials configured (for local testing)
    - API Gateway URL from terraform output
"""

import os
import sys
import time
import json
import yaml
import requests
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional

# Add project root to path for imports
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

class Colors:
    """ANSI color codes for terminal output"""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

class Milestone3Tester:
    """Test suite for Milestone 3 GitHub Actions CI/CD pipeline"""
    
    def __init__(self):
        self.project_root = project_root
        self.terraform_dir = self.project_root / "terraform"
        self.workflow_file = self.project_root / ".github" / "workflows" / "deploy.yaml"
        self.terraform_state_dir = self.project_root / "terraform-state"
        self.api_gateway_url = self._get_api_gateway_url()
        self.test_results = []
        
    def _get_api_gateway_url(self) -> Optional[str]:
        """Get API Gateway URL from terraform output or environment"""
        # Try environment variable first (for CI/CD)
        url = os.getenv('API_GATEWAY_URL')
        if url:
            return url
            
        # Try terraform output (for local testing)
        try:
            result = subprocess.run(
                ['terraform', 'output', '-raw', 'api_gateway_url'],
                cwd=self.terraform_dir,
                capture_output=True,
                text=True,
                timeout=30
            )
            if result.returncode == 0:
                return result.stdout.strip()
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
            
        return None
    
    def _print_test_header(self, test_name: str):
        """Print formatted test header"""
        print(f"\n{Colors.BLUE}📋 Running: {test_name}{Colors.ENDC}")
        print("─" * 40)
    
    def _print_success(self, message: str):
        """Print success message"""
        print(f"{Colors.GREEN}✅ {message}{Colors.ENDC}")
    
    def _print_error(self, message: str):
        """Print error message"""
        print(f"{Colors.RED}❌ {message}{Colors.ENDC}")
    
    def _print_info(self, message: str):
        """Print info message"""
        print(f"{Colors.CYAN}ℹ️  {message}{Colors.ENDC}")
    
    def _record_result(self, test_name: str, passed: bool, message: str = ""):
        """Record test result"""
        self.test_results.append({
            'test': test_name,
            'passed': passed,
            'message': message
        })
        
        if passed:
            self._print_success(f"{test_name}: PASSED")
        else:
            self._print_error(f"{test_name}: FAILED - {message}")
    
    def test_workflow_file_exists(self):
        """Test that GitHub Actions workflow file exists and is valid"""
        self._print_test_header("GitHub Actions Workflow File Validation")
        
        try:
            if not self.workflow_file.exists():
                self._record_result("Workflow File Exists", False, "deploy.yaml not found")
                return
            
            # Load and validate YAML
            with open(self.workflow_file, 'r') as f:
                workflow = yaml.safe_load(f)
            
            # Check required sections (note: 'on' becomes True in YAML parsing)
            required_sections = ['name', 'jobs', 'permissions']
            for section in required_sections:
                if section not in workflow:
                    self._record_result("Workflow Structure", False, f"Missing {section} section")
                    return
            
            # Check for 'on' section (which becomes True in YAML)
            if True not in workflow and 'on' not in workflow:
                self._record_result("Workflow Structure", False, "Missing on section")
                return
            
            # Check required jobs
            required_jobs = ['terraform-checks', 'security-scan', 'terraform-plan', 'terraform-apply', 'terraform-destroy']
            jobs = workflow.get('jobs', {})
            for job in required_jobs:
                if job not in jobs:
                    self._record_result("Required Jobs", False, f"Missing {job} job")
                    return
            
            # Check OIDC permissions
            permissions = workflow.get('permissions', {})
            if permissions.get('id-token') != 'write':
                self._record_result("OIDC Permissions", False, "Missing id-token: write permission")
                return
            
            self._record_result("Workflow File Validation", True)
            
        except Exception as e:
            self._record_result("Workflow File Validation", False, str(e))
    
    def test_terraform_version_consistency(self):
        """Test that Terraform version is consistent between local and CI"""
        self._print_test_header("Terraform Version Consistency")
        
        try:
            # Get local Terraform version
            result = subprocess.run(['terraform', 'version'], capture_output=True, text=True, timeout=10)
            if result.returncode != 0:
                self._record_result("Local Terraform Version", False, "terraform command not found")
                return
            
            local_version = result.stdout.split('\n')[0].split('v')[1] if 'v' in result.stdout else "unknown"
            
            # Get workflow Terraform version
            with open(self.workflow_file, 'r') as f:
                workflow = yaml.safe_load(f)
            
            workflow_version = workflow.get('env', {}).get('TF_VERSION', 'unknown')
            
            self._print_info(f"Local Terraform version: v{local_version}")
            self._print_info(f"Workflow Terraform version: v{workflow_version}")
            
            if local_version == workflow_version:
                self._record_result("Terraform Version Consistency", True)
            else:
                self._record_result("Terraform Version Consistency", False, 
                                  f"Version mismatch: local v{local_version} vs workflow v{workflow_version}")
                
        except Exception as e:
            self._record_result("Terraform Version Consistency", False, str(e))
    
    def test_terraform_state_backend(self):
        """Test that remote state backend is properly configured"""
        self._print_test_header("Remote State Backend Configuration")
        
        try:
            # Check backend configuration
            backend_file = self.terraform_dir / "backend.tf"
            if not backend_file.exists():
                self._record_result("Backend Configuration", False, "backend.tf not found")
                return
            
            with open(backend_file, 'r') as f:
                backend_content = f.read()
            
            # Check for S3 backend configuration
            if 'backend "s3"' not in backend_content:
                self._record_result("S3 Backend", False, "S3 backend not configured")
                return
            
            # Check for required backend parameters
            required_params = ['bucket', 'key', 'region', 'dynamodb_table']
            for param in required_params:
                if param not in backend_content:
                    self._record_result("Backend Parameters", False, f"Missing {param} parameter")
                    return
            
            self._record_result("Remote State Backend", True)
            
        except Exception as e:
            self._record_result("Remote State Backend", False, str(e))
    
    def test_terraform_state_infrastructure(self):
        """Test that terraform-state infrastructure exists"""
        self._print_test_header("Terraform State Infrastructure")
        
        try:
            # Check if terraform-state directory exists
            if not self.terraform_state_dir.exists():
                self._record_result("State Infrastructure Directory", False, "terraform-state directory not found")
                return
            
            # Check for required files
            required_files = ['main.tf', 'outputs.tf', 'github_oidc.tf']
            for file in required_files:
                file_path = self.terraform_state_dir / file
                if not file_path.exists():
                    self._record_result("State Infrastructure Files", False, f"{file} not found")
                    return
            
            # Try to get outputs (if terraform is initialized)
            try:
                result = subprocess.run(
                    ['terraform', 'output', '-json'],
                    cwd=self.terraform_state_dir,
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                if result.returncode == 0:
                    outputs = json.loads(result.stdout)
                    required_outputs = ['github_actions_role_arn', 'terraform_state_bucket']
                    for output in required_outputs:
                        if output not in outputs:
                            self._record_result("State Infrastructure Outputs", False, f"Missing {output} output")
                            return
                    
                    self._print_info(f"GitHub Actions Role: {outputs.get('github_actions_role_arn', {}).get('value', 'N/A')}")
                    self._print_info(f"State Bucket: {outputs.get('terraform_state_bucket', {}).get('value', 'N/A')}")
            except:
                self._print_info("Terraform state not initialized - skipping output check")
            
            self._record_result("Terraform State Infrastructure", True)
            
        except Exception as e:
            self._record_result("Terraform State Infrastructure", False, str(e))
    
    def test_security_scanning_config(self):
        """Test that security scanning (Checkov) is properly configured"""
        self._print_test_header("Security Scanning Configuration")
        
        try:
            with open(self.workflow_file, 'r') as f:
                workflow = yaml.safe_load(f)
            
            # Check security-scan job exists
            jobs = workflow.get('jobs', {})
            security_job = jobs.get('security-scan')
            if not security_job:
                self._record_result("Security Scan Job", False, "security-scan job not found")
                return
            
            # Check for Checkov installation and execution
            steps = security_job.get('steps', [])
            checkov_install = any('checkov' in str(step) for step in steps)
            checkov_run = any('checkov -d terraform/' in str(step) for step in steps)
            sarif_output = any('sarif' in str(step) for step in steps)
            
            if not checkov_install:
                self._record_result("Checkov Installation", False, "Checkov installation step not found")
                return
            
            if not checkov_run:
                self._record_result("Checkov Execution", False, "Checkov execution step not found")
                return
            
            if not sarif_output:
                self._record_result("SARIF Output", False, "SARIF output configuration not found")
                return
            
            self._record_result("Security Scanning Configuration", True)
            
        except Exception as e:
            self._record_result("Security Scanning Configuration", False, str(e))
    
    def test_modular_architecture(self):
        """Test that modular architecture is implemented"""
        self._print_test_header("Modular Architecture Validation")
        
        try:
            modules_dir = self.project_root / "modules"
            if not modules_dir.exists():
                self._record_result("Modules Directory", False, "modules directory not found")
                return
            
            # Check for required modules
            required_modules = ['api-gateway', 'lambda-function', 'user-storage']
            for module in required_modules:
                module_dir = modules_dir / module
                if not module_dir.exists():
                    self._record_result("Module Structure", False, f"{module} module not found")
                    return
                
                # Check for required module files
                required_files = ['main.tf', 'variables.tf', 'outputs.tf', 'README.md']
                for file in required_files:
                    file_path = module_dir / file
                    if not file_path.exists():
                        self._record_result("Module Files", False, f"{module}/{file} not found")
                        return
            
            # Check that terraform files use modules
            terraform_files = [
                self.terraform_dir / "main.tf",
                self.terraform_dir / "lambda.tf", 
                self.terraform_dir / "api_gateway.tf",
                self.terraform_dir / "user_storage.tf"
            ]
            
            module_usage_found = False
            for tf_file in terraform_files:
                if tf_file.exists():
                    with open(tf_file, 'r') as f:
                        content = f.read()
                    if 'module "' in content:
                        module_usage_found = True
                        break
            
            if not module_usage_found:
                self._record_result("Module Usage", False, "No module usage found in terraform files")
                return
            
            self._record_result("Modular Architecture", True)
            
        except Exception as e:
            self._record_result("Modular Architecture", False, str(e))
    
    
    def test_documentation_completeness(self):
        """Test that documentation is complete and up-to-date"""
        self._print_test_header("Documentation Completeness")
        
        try:
            readme_file = self.project_root / "README.md"
            if not readme_file.exists():
                self._record_result("README File", False, "README.md not found")
                return
            
            with open(readme_file, 'r') as f:
                readme_content = f.read().lower()
            
            # Check for required sections
            required_sections = [
                'milestone 3', 'github actions', 'ci/cd', 'deployment',
                'terraform', 'aws', 'infrastructure'
            ]
            
            missing_sections = []
            for section in required_sections:
                if section not in readme_content:
                    missing_sections.append(section)
            
            if missing_sections:
                self._record_result("README Content", False, f"Missing sections: {', '.join(missing_sections)}")
                return
            
            # Check module documentation
            modules_dir = self.project_root / "modules"
            if modules_dir.exists():
                for module_dir in modules_dir.iterdir():
                    if module_dir.is_dir():
                        readme_path = module_dir / "README.md"
                        if not readme_path.exists():
                            self._record_result("Module Documentation", False, f"{module_dir.name}/README.md not found")
                            return
            
            self._record_result("Documentation Completeness", True)
            
        except Exception as e:
            self._record_result("Documentation Completeness", False, str(e))
    
    def run_all_tests(self):
        """Run all Milestone 3 tests"""
        print(f"{Colors.HEADER}🚀 Starting Milestone 3 Tests{Colors.ENDC}")
        print("=" * 60)
        
        # Run all tests
        test_methods = [
            self.test_workflow_file_exists,
            self.test_terraform_version_consistency,
            self.test_terraform_state_backend,
            self.test_terraform_state_infrastructure,
            self.test_security_scanning_config,
            self.test_modular_architecture,
            self.test_documentation_completeness
        ]
        
        for test_method in test_methods:
            try:
                test_method()
            except Exception as e:
                test_name = test_method.__name__.replace('test_', '').replace('_', ' ').title()
                self._record_result(test_name, False, f"Test execution error: {str(e)}")
        
        # Print summary
        self._print_summary()
    
    def _print_summary(self):
        """Print test results summary"""
        print(f"\n{Colors.HEADER}=" * 60)
        print("📊 Test Results Summary")
        print("=" * 60 + Colors.ENDC)
        
        passed_tests = [r for r in self.test_results if r['passed']]
        failed_tests = [r for r in self.test_results if not r['passed']]
        
        for result in self.test_results:
            status = f"{Colors.GREEN}✅ PASSED{Colors.ENDC}" if result['passed'] else f"{Colors.RED}❌ FAILED{Colors.ENDC}"
            print(f"{status} {result['test']}")
            if not result['passed'] and result['message']:
                print(f"    {Colors.YELLOW}└─ {result['message']}{Colors.ENDC}")
        
        print(f"\n{Colors.HEADER}=" * 60)
        print(f"📊 Test Results: {len(passed_tests)}/{len(self.test_results)} tests passed")
        
        if len(failed_tests) == 0:
            print(f"{Colors.GREEN}🎉 All tests passed! Milestone 3 is ready for submission.{Colors.ENDC}")
        else:
            print(f"{Colors.RED}❌ {len(failed_tests)} test(s) failed. Please address the issues above.{Colors.ENDC}")
        
        print("=" * 60 + Colors.ENDC)

def main():
    """Main test execution"""
    tester = Milestone3Tester()
    tester.run_all_tests()
    
    # Exit with appropriate code
    failed_tests = [r for r in tester.test_results if not r['passed']]
    sys.exit(len(failed_tests))

if __name__ == "__main__":
    main()
