param(
  [string]$Title = "Session ending soon",
  [string]$Message = "Your session ends in 5 minutes.",
  [int]$Seconds = 15
)

Add-Type -AssemblyName PresentationFramework

$window = New-Object Windows.Window
$window.Title = $Title
$window.WindowStyle = 'None'
$window.ResizeMode = 'NoResize'
$window.WindowState = 'Maximized'
$window.Topmost = $true
$window.ShowInTaskbar = $false
$window.Background = [Windows.Media.Brushes]::Black
$window.Opacity = 0.85

$grid = New-Object Windows.Controls.Grid
$grid.Margin = '60'
$window.Content = $grid

$stack = New-Object Windows.Controls.StackPanel
$stack.VerticalAlignment = 'Center'
$stack.HorizontalAlignment = 'Center'
$stack.Orientation = 'Vertical'
$stack.MaxWidth = 1400
$grid.Children.Add($stack) | Out-Null

$titleBlock = New-Object Windows.Controls.TextBlock
$titleBlock.Text = $Title
$titleBlock.FontSize = 78
$titleBlock.FontWeight = 'Bold'
$titleBlock.Foreground = [Windows.Media.Brushes]::White
$titleBlock.TextAlignment = 'Center'
$titleBlock.Margin = '0,0,0,20'
$stack.Children.Add($titleBlock) | Out-Null

$msgBlock = New-Object Windows.Controls.TextBlock
$msgBlock.Text = $Message
$msgBlock.FontSize = 48
$msgBlock.Foreground = [Windows.Media.Brushes]::White
$msgBlock.TextAlignment = 'Center'
$msgBlock.TextWrapping = 'Wrap'
$stack.Children.Add($msgBlock) | Out-Null

$subBlock = New-Object Windows.Controls.TextBlock
$subBlock.Text = "This message will close automatically."
$subBlock.FontSize = 26
$subBlock.Foreground = [Windows.Media.Brushes]::Gray
$subBlock.TextAlignment = 'Center'
$subBlock.Margin = '0,30,0,0'
$stack.Children.Add($subBlock) | Out-Null

$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds($Seconds)
$timer.Add_Tick({
  $timer.Stop()
  $window.Close()
})
$timer.Start()

$window.Add_Loaded({ $window.Activate() | Out-Null })
$window.ShowDialog() | Out-Null
