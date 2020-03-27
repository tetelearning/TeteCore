using System;
using System.Linq;
using Tete.Api.Contexts;
using Tete.Api.Services.Localization;
using Tete.Models.Authentication;

namespace Tete.Api.Services.Users
{
  public class ProfileService
  {

    private MainContext mainContext;
    private UserLanguageService userLanguageService;

    public ProfileService(MainContext mainContext)
    {
      this.mainContext = mainContext;
      this.userLanguageService = new UserLanguageService(mainContext);
    }

    public UserVM GetUser(Guid UserId)
    {
        return GetUser(this.mainContext.Users.Where(u => u.Id == UserId).FirstOrDefault());
    }

    public UserVM GetUser(User user)
    {
        return new UserVM(user,
          this.userLanguageService.GetUserLanguages(user.Id),
          this.mainContext.UserProfiles.Where(p => p.UserId == user.Id).FirstOrDefault());
    }

  }
}