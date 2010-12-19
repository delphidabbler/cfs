inherited FileNameViewerFrame: TFileNameViewerFrame
  inherited pnlView: TPanel
    inherited lblName: TLabel
      Width = 50
      Caption = 'File Name:'
    end
  end
  inherited alView: TActionList
    inherited actExec: TAction
      OnExecute = actExecExecute
    end
  end
end
