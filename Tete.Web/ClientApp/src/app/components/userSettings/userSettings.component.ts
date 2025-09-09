import { Component } from "@angular/core";
import { Router } from "@angular/router";
import { User } from "../../models/user";
import { InitService } from "../../services/init.service";
import { ApiService } from "../../services/api.service";
import { UserService } from "../../services/user.service";

@Component({
  selector: "user-settings",
  templateUrl: "./userSettings.component.html"
})
export class UserSettingsComponent {
  public currentUser: User = new User(null);
  public working: Working = new Working();

  constructor(
    private apiService: ApiService,
    private userService: UserService,
    private initService: InitService,
    private router: Router
  ) {
    this.initService.Register(() => this.load());
  }

  private load() {
    this.currentUser = this.userService.CurrentUser();
    this.working.registration = new Registration();
    this.working.registration.userName = this.currentUser.userName;
  }

  public resetPassword() {
    this.apiService
      .post('/Login/ResetPassword', { password: this.working.registration.password })
      .then(r => this.processRegistrationResponse(r[0], '/'));
  }

  public updateUserName() {
    this.apiService
      .post('/Login/UpdateUserName', { userName: this.working.registration.userName })
      .then(r => this.processRegistrationResponse(r[0], '/'));
  }

  public registerNewLogin() {
    this.apiService.post('/Login/RegisterNewLogin', this.working.registration).then(r => this.processRegistrationResponse(r[0], '/profile'));
  }

  public login() {
    this.apiService.post('/Login/Login', this.working.registration).then(r => this.processRegistrationResponse(r[0], '/'));
  }

  public finalizeDelete() {
    this.apiService.post('/Login/AdminDelete', { userId: this.currentUser.userId, name: '' }).then(() => {
      location.href = '/Login/Logout';
    });
  }

  private async processRegistrationResponse(response, navigation: string) {
    {
      if (response.successful) {
        await this.initService.Load();
        this.router.navigate([navigation]);
      } else {
        this.working.responseMessages = response.messages;
      }
    }
  }
}

class Working {

  public responseMessages: Array<string>;
  public registration: Registration;
  public deleting: boolean;
  public deleteText: string;

  constructor() {
    this.responseMessages = [];
    this.registration = new Registration();
    this.deleting = false;
    this.deleteText = '';
  }
};

class Registration {
  public checkedTOS: boolean;
  public displayPassword: boolean;
  public userName: string;
  public password: string;

  constructor() {
    this.checkedTOS = false;
    this.displayPassword = false;
    this.userName = '';
    this.password = '';
  }
}