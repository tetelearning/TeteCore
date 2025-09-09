import { Component, Input } from '@angular/core';
import { Topic } from '../../models/topic';
import { Mentorship } from '../../models/mentorship';
import { User } from '../../models/user';
import { InitService } from '../../services/init.service';
import { UserService } from '../../services/user.service';

@Component({
  selector: 'teteTile',
  templateUrl: './tile.component.html'
})
export class TileComponent {
  @Input('topic') topic: Topic;
  @Input('mentorship') mentorship: Mentorship;

  public currentUser: User;

  constructor(private initService: InitService,
    private userService: UserService) {
    initService.Register(() => {
      this.currentUser = userService.CurrentUser()
    });
  }
}