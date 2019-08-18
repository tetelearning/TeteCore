using System;

namespace Tete.Models.Logging
{

  public class Log
  {
    public Guid LogId { get; set; }

    public DateTime Occured { get; set; }

    public string Description { get; set; }

    public string MachineName { get; set; }

    public string StackTrace { get; set; }

    public Log()
    {
      Init();
    }

    public Log(string Description)
    {
      Init();
      this.Description = Description;
    }

    private void Init()
    {
      this.LogId = Guid.NewGuid();
      this.Occured = DateTime.UtcNow;
      this.MachineName = Environment.MachineName;
      this.StackTrace = Environment.StackTrace;
    }

  }

}