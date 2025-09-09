using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.SpaServices.AngularCli;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using System;
using LettuceEncrypt;

namespace Tete.Web
{
  public class Startup
  {
    public Startup(IConfiguration configuration)
    {
      Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
      services.AddMvc(setup =>
      {
        setup.EnableEndpointRouting = false;
      });
      services.AddDbContext<Tete.Api.Contexts.MainContext>(options => options.UseSqlServer(Configuration["ConnectionStrings:DefaultConnection"], sqlOptions => sqlOptions.EnableRetryOnFailure()));

      services.AddHttpsRedirection(opts =>
      {
        opts.RedirectStatusCode = 308;
        opts.HttpsPort = 443;
      });

      services.AddHttpsRedirection(opts =>
      {
        opts.RedirectStatusCode = 307;
        opts.HttpsPort = 443;
      });

      services.AddHsts(opts =>
      {
        opts.Preload = true;
        opts.IncludeSubDomains = true;
        opts.MaxAge = TimeSpan.FromHours(2);
      });

      services
        .AddLettuceEncrypt()
        .PersistDataToDirectory(new System.IO.DirectoryInfo("/var/opt/ssl"), Environment.GetEnvironmentVariable("Certificate_Password"));

      // In production, the Angular files will be served from this directory
      // Angular 18+ outputs to dist/browser/ subdirectory
      services.AddSpaStaticFiles(configuration =>
      {
        configuration.RootPath = "ClientApp/dist/browser";
      });
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
      if (env.IsDevelopment())
      {
        // app.UseExceptionHandler("/Error");
        app.UseDeveloperExceptionPage();
      }
      else
      {
        app.UseExceptionHandler("/Error");
        // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
        app.UseHsts();
        app.UseHttpsRedirection();
      }
      app.UseStaticFiles();
      app.UseSpaStaticFiles();

      app.UseMvc(routes =>
      {
        routes.MapRoute(
          name: "default",
          template: "{controller}/{action=Index}/{id?}"
        );
      });

      app.UseSpa(spa =>
      {
        // To learn more about options for serving an Angular SPA from ASP.NET Core,
        // see https://go.microsoft.com/fwlink/?linkid=864501

        spa.Options.SourcePath = "ClientApp";
        spa.Options.DefaultPage = "/index.html";

        if (env.IsDevelopment())
        {
          // In containerized development, serve pre-built static files from the browser subfolder (Angular 18+)
          spa.Options.DefaultPageStaticFileOptions = new StaticFileOptions
          {
            OnPrepareResponse = ctx => {
              ctx.Context.Response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate");
            }
          };
        }
      });
    }
  }
}
