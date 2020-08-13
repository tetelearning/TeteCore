import { Injectable, Inject } from "@angular/core";
import { HttpClient, HttpErrorResponse } from "@angular/common/http";

@Injectable({
  providedIn: "root"
})
export class ApiService {
  private http: HttpClient;
  private user;

  constructor(http: HttpClient) {
    this.http = http;
  }

  get(url): Promise<any[]> {
    return this.http
      .get<Response>(url)
      .toPromise()
      .then(result => {
        return result.data;
      })
      .catch(this.handleError);
  }

  authTest() {
    // TODO: Add authtest to each call but also not require it to be a full round trip on most cases.
    // TODO: Determine the "logged out" functionality for if someone comes to the site before logging in.
    return this.http
      .get("/Login/CurrentUser")
      .toPromise()
      .then(user => {
        this.user = user;
        return user;
      })
      .catch(this.handleError);
  }

  post(url: string, body: object): Promise<any[]> {
    return this.http
      .post<Response>(url, body)
      .toPromise()
      .then(res => {
        return res.data;
      })
      .catch(this.handleError);
  }

  put(url: string, body: object) {
    return this.http
      .put(url, body)
      .toPromise()
      .catch(this.handleError);
  }

  private handleError(error: HttpErrorResponse) {
    if (error.status == 401) {
      // UnAuthorized
      window.location.href = "/Login";
    }
    return [{}];
  }
}

interface Response {
  request: Request;
  data: object[];
  error: boolean;
  message: string;
  status: number;
}

interface Request {
  url: string;
  method: string;
  body: string;
}
