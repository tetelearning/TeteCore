using System;
using System.Collections.Generic;
using Moq;
using NUnit.Framework;
using Tete.Api.Services.Users;
using Tete.Tests.Setup;

namespace Tete.Tests.Api.Services.Users
{
    public class UserServiceTests : UserTestBase
    {
        private ProfileService profileService;

        [SetUp]
        public void SetupTests()
        {
            this.profileService = new ProfileService(mockContext.Object);
        }

        [Test]
        public void SanityTest()
        {
            Assert.IsTrue(true);
        }

        [Test]
        public void GetProfileTest()
        {
            Assert.Inconclusive("Need to implement this.");
        }
    }

}