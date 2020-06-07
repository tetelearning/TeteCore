using System;
using System.Linq;
using Tete.Api.Contexts;
using Tete.Api.Services.Localization;
using Tete.Models.Authentication;
using Tete.Models.Users;

namespace Tete.Api.Services.Users
{
  public class ProfileService : ServiceBase
  {

    private UserLanguageService userLanguageService;

    public ProfileService(MainContext mainContext, UserVM actor)
    {
      FillData(mainContext, actor);
    }

    public ProfileService(MainContext mainContext, User actor)
    {
      FillData(mainContext, new UserVM());
      this.Actor = GetUser(actor);
    }

    public UserVM GetUser(Guid UserId)
    {
      return GetUser(this.mainContext.Users.Where(u => u.Id == UserId).FirstOrDefault());
    }

    public UserVM GetUser(User user)
    {
      var languages = this.userLanguageService.GetUserLanguages(user.Id);
      var profiles = this.mainContext.UserProfiles.Where(p => p.UserId == user.Id).FirstOrDefault();
      var roles = this.mainContext.AccessRoles.Where(r => r.UserId == user.Id).ToList();
      return new UserVM(
        user,
        languages,
        profiles,
        roles
      );
    }

    public void SaveProfile(Profile profile)
    {
      this.mainContext.UserProfiles.Add(profile);
      this.mainContext.SaveChanges();
    }

    private void FillData(MainContext mainContext, UserVM actor)
    {
      this.mainContext = mainContext;
      this.Actor = actor;
      this.userLanguageService = new UserLanguageService(mainContext);
    }
  }
}