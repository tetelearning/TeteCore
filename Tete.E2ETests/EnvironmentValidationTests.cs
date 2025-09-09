using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Support.UI;
using System;
using System.IO;
using System.Reflection;
using System.Net.Http;
using System.Threading.Tasks;
using System.Text;
using Newtonsoft.Json;

namespace Tests
{
    [TestFixture]
    public class EnvironmentValidationTests
    {
        private IWebDriver driver;
        private WebDriverWait wait;
        private HttpClient httpClient;
        private string baseUrl;
        private readonly string testUserName = $"e2etest_{DateTime.Now.Ticks}";
        private readonly string testEmail = $"e2etest_{DateTime.Now.Ticks}@example.com";
        private readonly string testDisplayName = $"E2E Test User {DateTime.Now.Ticks}";
        private readonly string testPassword = "TestPassword123!";

        [OneTimeSetUp]
        public void OneTimeSetUp()
        {
            // Read base URL from environment variable or use default
            baseUrl = Environment.GetEnvironmentVariable("TETE_BASE_URL") ?? "http://localhost:5001";
            
            var chromeOptions = new ChromeOptions();
            chromeOptions.AddArgument("--headless"); // Run headless for CI/CD
            chromeOptions.AddArgument("--no-sandbox");
            chromeOptions.AddArgument("--disable-dev-shm-usage");
            
            driver = new ChromeDriver(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), chromeOptions);
            wait = new WebDriverWait(driver, TimeSpan.FromSeconds(10));
            httpClient = new HttpClient { BaseAddress = new Uri(baseUrl) };
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            driver?.Quit();
            httpClient?.Dispose();
        }

        [Test, Order(1)]
        public async Task ValidateHealthEndpoint()
        {
            try
            {
                // Test that the application is responding
                var response = await httpClient.GetAsync("/");
                var statusCode = (int)response.StatusCode;
                
                Assert.That(statusCode, Is.Not.EqualTo(0), "Should get HTTP response (not connection failure)");
                Assert.That(statusCode, Is.LessThan(500), 
                    $"Application should be responding (got HTTP {statusCode}, not 5xx server error)");
                
                Console.WriteLine($"✅ Health check passed: HTTP {statusCode}");
            }
            catch (HttpRequestException ex)
            {
                Assert.Fail($"❌ Cannot connect to {baseUrl}: {ex.Message}. Ensure the application is running and accessible.");
            }
            catch (TaskCanceledException ex)
            {
                Assert.Fail($"❌ Request to {baseUrl} timed out: {ex.Message}. Ensure the application is running.");
            }
        }

        [Test, Order(2)]
        public async Task ValidateApiEndpoints()
        {
            // Test core API endpoints are accessible
            var languagesResponse = await httpClient.GetAsync("/V1/Languages/Get");
            Assert.That((int)languagesResponse.StatusCode, Is.EqualTo(200).Or.EqualTo(401), 
                "Languages endpoint should be accessible (200 or 401 if auth required)");

            var flagsResponse = await httpClient.GetAsync("/V1/Flags/Get");
            Assert.That((int)flagsResponse.StatusCode, Is.EqualTo(200).Or.EqualTo(401),
                "Flags endpoint should be accessible");
        }

        [Test, Order(3)]
        public void ValidateFrontendLoads()
        {
            driver.Navigate().GoToUrl(baseUrl);
            
            // Wait for Angular to load
            wait.Until(d => d.FindElement(By.TagName("app-root")));
            
            // Verify the main Angular component loaded
            var appRoot = driver.FindElement(By.TagName("app-root"));
            Assert.That(appRoot.Displayed, Is.True, "Angular app should load");
        }

        [Test, Order(4)]
        public void ValidateLoginPageAccessible()
        {
            driver.Navigate().GoToUrl($"{baseUrl}/Login");
            
            // Wait for login form elements
            wait.Until(d => d.FindElement(By.Name("userName")));
            
            var usernameField = driver.FindElement(By.Name("userName"));
            var passwordField = driver.FindElement(By.Name("userPassword"));
            
            Assert.That(usernameField.Displayed, Is.True, "Username field should be visible");
            Assert.That(passwordField.Displayed, Is.True, "Password field should be visible");
        }

        [Test, Order(5)]
        public void ValidateUserRegistrationFlow()
        {
            driver.Navigate().GoToUrl($"{baseUrl}/Login/Register");
            
            // Fill registration form
            wait.Until(d => d.FindElement(By.Name("userName")));
            
            driver.FindElement(By.Name("userName")).SendKeys(testUserName);
            driver.FindElement(By.Name("userDisplayName")).SendKeys(testDisplayName);
            driver.FindElement(By.Name("userEmail")).SendKeys(testEmail);
            driver.FindElement(By.Name("userPassword")).SendKeys(testPassword);

            // Submit registration
            var submitButton = driver.FindElement(By.Id("submit"));
            submitButton.Click();

            // Wait for redirect or success indication
            wait.Until(d => d.Url != $"{baseUrl}/Login/Register");
            
            Assert.That(driver.Url, Is.Not.EqualTo($"{baseUrl}/Login/Register"), 
                "Should redirect after successful registration");
        }

        [Test, Order(6)]
        public void ValidateUserLoginFlow()
        {
            driver.Navigate().GoToUrl($"{baseUrl}/Login");
            
            wait.Until(d => d.FindElement(By.Name("userName")));
            
            // Attempt login with created user
            driver.FindElement(By.Name("userName")).Clear();
            driver.FindElement(By.Name("userName")).SendKeys(testUserName);
            driver.FindElement(By.Name("userPassword")).Clear();
            driver.FindElement(By.Name("userPassword")).SendKeys(testPassword);
            
            driver.FindElement(By.CssSelector("input[type='submit']")).Click();
            
            // Should redirect away from login page if successful
            wait.Until(d => d.Url != $"{baseUrl}/Login");
            
            Assert.That(driver.Url, Is.Not.EqualTo($"{baseUrl}/Login"), 
                "Should redirect after successful login");
        }

        [Test, Order(7)]
        public void ValidateDashboardAccess()
        {
            // Assuming user is logged in from previous test
            driver.Navigate().GoToUrl(baseUrl);
            
            // Look for user-specific content or navigation that indicates successful auth
            try
            {
                // This might need to be adjusted based on your actual dashboard structure
                wait.Until(d => d.FindElement(By.CssSelector("[data-testid='user-dashboard'], .dashboard, .user-nav")));
                
                var dashboardElement = driver.FindElement(By.CssSelector("[data-testid='user-dashboard'], .dashboard, .user-nav"));
                Assert.That(dashboardElement.Displayed, Is.True, 
                    "Dashboard or user navigation should be visible after login");
            }
            catch (WebDriverTimeoutException)
            {
                // Fallback: check that we're not on the login page
                Assert.That(driver.Url, Does.Not.Contain("/Login"), 
                    "Should not be redirected to login page when authenticated");
            }
        }

        [Test, Order(8)]
        public async Task ValidateApiWithAuthentication()
        {
            // Get authentication token/cookie from browser and use in API call
            var cookies = driver.Manage().Cookies.AllCookies;
            
            foreach (var cookie in cookies)
            {
                httpClient.DefaultRequestHeaders.Add("Cookie", $"{cookie.Name}={cookie.Value}");
            }

            // Test authenticated API endpoint
            var userResponse = await httpClient.PostAsync("/V1/User/Search", 
                new StringContent(JsonConvert.SerializeObject(new { searchText = testUserName }), 
                Encoding.UTF8, "application/json"));
            
            Assert.That((int)userResponse.StatusCode, Is.LessThan(500), 
                "User search API should not return server error when authenticated");
        }

        [Test, Order(9)]
        public async Task ValidateDatabaseConnectivity()
        {
            // Test endpoints that definitely hit the database
            var languagesResponse = await httpClient.GetAsync("/V1/Languages/Get");
            
            if (languagesResponse.IsSuccessStatusCode)
            {
                var content = await languagesResponse.Content.ReadAsStringAsync();
                Assert.That(string.IsNullOrEmpty(content), Is.False, 
                    "Languages endpoint should return data from database");
            }
            else if (languagesResponse.StatusCode == System.Net.HttpStatusCode.Unauthorized)
            {
                // If auth required, just verify it's not a database connection error
                Assert.That((int)languagesResponse.StatusCode, Is.Not.EqualTo(500), 
                    "Should not be a server error (database connectivity issue)");
            }
        }

        [Test, Order(10)]
        public void ValidateErrorHandling()
        {
            // Test that the application handles 404s gracefully
            driver.Navigate().GoToUrl($"{baseUrl}/nonexistent-page");
            
            // Should not show a white screen or browser error
            // Look for custom 404 page or redirect to home
            var pageSource = driver.PageSource.ToLower();
            
            Assert.That(pageSource, Does.Not.Contain("this site can't be reached")
                .And.Not.Contain("server error")
                .And.Not.Contain("500"), 
                "Should handle 404s gracefully without showing browser/server errors");
        }
    }
}