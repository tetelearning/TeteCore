using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Tete.Api.Services.Localization;
using Tete.Models.Authentication;
using Tete.Models.Localization;


namespace Tete.Api.Controllers
{
  [Route("[controller]")]
  [ApiController]
  public class InitController : ControllerBase
  {
    private LoginController loginController;
    private LanguageService languageService;

    public InitController(Contexts.MainContext mainContext)
    {
      this.loginController = new LoginController(mainContext);
      this.languageService = new LanguageService(mainContext);
    }
    // GET api/values
    [HttpGet]
    public List<string> Get()
    {
      var output = new List<string>();
      this.loginController.Register(new RegistrationAttempt()
      {
        UserName = "admin",
        Email = "admin@example.com",
        Password = "admin",
        DisplayName = "Admin"
      });
      output.Add("User 'Admin' created.");


      var english = new Language()
      {
        LanguageId = Guid.NewGuid(),
        Name = "English",
        Active = true,
        Elements = new List<Element>()
      };

      english.Elements.Add(new Element()
      {
        ElementId = Guid.NewGuid(),
        Key = "welcome",
        Text = "Welcome!",
        LanguageId = english.LanguageId
      });

      this.languageService.CreateLanguage(english);
      output.Add("Created English Language");

      return output;
    }
  }
}