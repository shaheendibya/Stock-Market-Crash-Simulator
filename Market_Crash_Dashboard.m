% Save this file as: Market_Crash_Dashboard.m
function Market_Crash_Dashboard()
    clear; clc; close all;

    %% Global Application State
    run_count = 0;
    history_runs = struct('p', {}, 'v', {}, 'asset', {}, 'state', {}, 'crashed', {});
    history_table_data = {};
    
    % Active Parameters
    params.S0 = 100;
    params.N = 252;
    params.mu_bull = 0.08;   
    params.sigma_bull = 0.12; 
    params.thresh = 0.0015;
    params.animate = false;

    %% 1. Main Window
    fig = uifigure('Name', 'Financial Market Monitoring and Prediction System', ...
                   'Position', [80, 50, 1200, 720], ...
                   'Color', [0.08, 0.10, 0.15]);

    %% 2. Left Navigation Sidebar
    p_side = uipanel(fig, 'Position', [10, 10, 170, 700], ...
                     'BackgroundColor', [0.05, 0.07, 0.11], 'ForegroundColor', 'none');
                 
    uilabel(p_side, 'Text', 'MARKET', 'Position', [15, 650, 140, 25], ...
            'FontWeight', 'bold', 'FontSize', 18, 'FontColor', [1 1 1], 'HorizontalAlignment', 'center');
    uilabel(p_side, 'Text', 'MONITOR', 'Position', [15, 625, 140, 25], ...
            'FontWeight', 'bold', 'FontSize', 18, 'FontColor', [0.3 0.6 1.0], 'HorizontalAlignment', 'center');

    % Navigation Buttons
    btn_dash   = uibutton(p_side, 'Text', 'Dashboard', 'Position', [15, 540, 140, 40], 'BackgroundColor', [0.15, 0.45, 0.85], 'FontColor', [1 1 1], 'FontWeight', 'bold');
    btn_sim    = uibutton(p_side, 'Text', 'Simulate',  'Position', [15, 480, 140, 40], 'BackgroundColor', [0.12, 0.16, 0.24], 'FontColor', [0.9 0.9 0.9], 'FontWeight', 'bold');
    btn_hist   = uibutton(p_side, 'Text', 'History',   'Position', [15, 420, 140, 40], 'BackgroundColor', [0.12, 0.16, 0.24], 'FontColor', [0.9 0.9 0.9], 'FontWeight', 'bold');
    btn_export = uibutton(p_side, 'Text', 'Export Data', 'Position', [15, 360, 140, 40], 'BackgroundColor', [0.12, 0.16, 0.24], 'FontColor', [0.9 0.9 0.9], 'FontWeight', 'bold');
    btn_sett   = uibutton(p_side, 'Text', 'Settings',  'Position', [15, 300, 140, 40], 'BackgroundColor', [0.12, 0.16, 0.24], 'FontColor', [0.9 0.9 0.9], 'FontWeight', 'bold');

    %% 3. VIEW 1: DASHBOARD
    v_dash = uipanel(fig, 'Position', [190, 10, 1000, 700], 'BackgroundColor', [0.08, 0.10, 0.15], 'ForegroundColor', 'none');

    % Controls Panel
    p_select = uipanel(v_dash, 'Title', 'Asset Controls', 'Position', [0, 530, 280, 160], ...
                       'BackgroundColor', [0.12, 0.15, 0.22], 'ForegroundColor', [0.7 0.8 1.0], 'FontWeight', 'bold');
    uilabel(p_select, 'Text', 'Preset Profile:', 'Position', [15, 110, 100, 20], 'FontColor', [0.8 0.8 0.8]);
    dd_asset = uidropdown(p_select, 'Items', {'Tech Index (Volatile)', 'S&P 500 Baseline', 'Crypto Asset (High Risk)'}, ...
                          'Position', [15, 85, 250, 25], 'BackgroundColor', [0.2 0.25 0.35], 'FontColor', [1 1 1]);
    btn_run = uibutton(p_select, 'Text', 'Run Simulation', 'Position', [15, 20, 120, 38], ...
                        'BackgroundColor', [0.15, 0.65, 0.35], 'FontColor', [1 1 1], 'FontWeight', 'bold');
    cb_anim = uicheckbox(p_select, 'Text', 'Live Playback', 'Position', [145, 28, 120, 20], ...
                         'FontColor', [0.9 0.9 0.9], 'Value', false);

    % Market Parameters Display
    p_params = uipanel(v_dash, 'Title', 'Active Model Parameters', 'Position', [290, 530, 290, 160], ...
                       'BackgroundColor', [0.12, 0.15, 0.22], 'ForegroundColor', [0.7 0.8 1.0], 'FontWeight', 'bold');
    lbl_drift = uilabel(p_params, 'Text', 'Baseline Drift (\mu): 0.08', 'Position', [15, 105, 260, 20], 'FontColor', [0.9 0.9 0.9]);
    lbl_vol   = uilabel(p_params, 'Text', 'Volatility (\sigma): 0.12', 'Position', [15, 80, 260, 20], 'FontColor', [0.9 0.9 0.9]);
    lbl_th    = uilabel(p_params, 'Text', 'Threshold (H_1): 0.0015', 'Position', [15, 55, 260, 20], 'FontColor', [0.9 0.9 0.9]);
    uilabel(p_params, 'Text', 'Analysis: Price Action Based', 'Position', [15, 30, 260, 20], 'FontColor', [0.3 0.9 0.4]);

    % Risk Gauge
    p_gauge = uipanel(v_dash, 'Title', 'Crash Risk Gauge', 'Position', [590, 530, 400, 160], ...
                      'BackgroundColor', [0.12, 0.15, 0.22], 'ForegroundColor', [0.7 0.8 1.0], 'FontWeight', 'bold');
    gauge = uigauge(p_gauge, 'semicircular', 'Position', [120, 20, 160, 110], ...
                    'Limits', [0 100], 'ScaleColors', [0.2 0.8 0.3; 0.9 0.7 0.2; 0.9 0.2 0.2], ...
                    'ScaleColorLimits', [0 35; 35 70; 70 100], 'Value', 0);
    lbl_risk_val = uilabel(p_gauge, 'Text', 'Risk: 0.0%', 'Position', [10, 5, 380, 22], ...
                           'FontWeight', 'bold', 'FontSize', 15, 'FontColor', [0.3 1.0 0.4], 'HorizontalAlignment', 'center');

    % Hypothesis & Price Trend Cards
    p_estimation = uipanel(v_dash, 'Title', 'Parameter & Crash Alarm', 'Position', [0, 390, 480, 130], ...
                           'BackgroundColor', [0.12, 0.15, 0.22], 'ForegroundColor', [0.7 0.8 1.0], 'FontWeight', 'bold');
    lbl_var_est = uilabel(p_estimation, 'Text', 'Est. Daily Variance: 0.000000', 'Position', [15, 75, 450, 22], 'FontSize', 14, 'FontColor', [0.9 0.9 0.9]);
    lbl_hypo    = uilabel(p_estimation, 'Text', 'Status: H_0 Accepted (Market Stable)', 'Position', [15, 40, 450, 25], ...
                          'FontSize', 15, 'FontWeight', 'bold', 'FontColor', [0.3 1.0 0.4]);

    p_markov = uipanel(v_dash, 'Title', 'Realized Price Momentum', 'Position', [490, 390, 500, 130], ...
                       'BackgroundColor', [0.12, 0.15, 0.22], 'ForegroundColor', [0.7 0.8 1.0], 'FontWeight', 'bold');
    uilabel(p_markov, 'Text', 'Realized Direction (Recent Price Action):', 'Position', [15, 75, 450, 20], 'FontColor', [0.8 0.8 0.8]);
    lbl_state = uilabel(p_markov, 'Text', 'UPWARD BULLISH', 'Position', [15, 35, 450, 35], ...
                        'FontSize', 20, 'FontWeight', 'bold', 'FontColor', [0.3 1.0 0.4]);

    % Main Graph
    ax_plot = uiaxes(v_dash, 'Position', [0, 10, 990, 360], ...
                     'BackgroundColor', [0.06, 0.08, 0.12], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], ...
                     'GridColor', [0.2 0.25 0.35]);
    title(ax_plot, 'Real-Time Geometric Brownian Motion Path & Crash Detection', 'Color', [0.9 0.9 0.9]);
    xlabel(ax_plot, 'Trading Days', 'Color', [0.8 0.8 0.8]); ylabel(ax_plot, 'Asset Price ($)', 'Color', [0.8 0.8 0.8]);
    grid(ax_plot, 'on');

    %% 4. VIEW 2: HISTORY INSPECTOR
    v_hist = uipanel(fig, 'Position', [190, 10, 1000, 700], 'BackgroundColor', [0.08, 0.10, 0.15], 'ForegroundColor', 'none', 'Visible', 'off');
    uilabel(v_hist, 'Text', 'Simulation History Log & Inspector', 'Position', [20, 650, 400, 30], 'FontSize', 20, 'FontWeight', 'bold', 'FontColor', [1 1 1]);
    
    tbl_hist = uitable(v_hist, 'Position', [20, 100, 950, 530], ...
                       'ColumnName', {'Run #', 'Selected Asset', 'Final Price ($)', 'Max Variance', 'Realized Price Direction', 'Crash Flagged'}, ...
                       'ColumnWidth', {80, 200, 140, 140, 200, 140}, ...
                       'BackgroundColor', [0.12 0.15 0.22; 0.08 0.10 0.15], 'ForegroundColor', [1 1 1], ...
                       'SelectionType', 'row');
                   
    btn_load_hist = uibutton(v_hist, 'Text', 'Re-Plot Selected Run', 'Position', [20, 30, 180, 42], ...
                             'BackgroundColor', [0.15, 0.45, 0.85], 'FontColor', [1 1 1], 'FontWeight', 'bold', 'FontSize', 13);
    btn_clear_hist = uibutton(v_hist, 'Text', 'Clear All Logs', 'Position', [220, 30, 140, 42], ...
                              'BackgroundColor', [0.85 0.25 0.25], 'FontColor', [1 1 1], 'FontWeight', 'bold', 'FontSize', 13);

    %% 5. VIEW 3: INTERACTIVE SETTINGS WORKSPACE
    v_sett = uipanel(fig, 'Position', [190, 10, 1000, 700], 'BackgroundColor', [0.08, 0.10, 0.15], 'ForegroundColor', 'none', 'Visible', 'off');
    uilabel(v_sett, 'Text', 'Interactive Model Configuration', 'Position', [20, 650, 500, 30], 'FontSize', 20, 'FontWeight', 'bold', 'FontColor', [1 1 1]);

    p_sett_card = uipanel(v_sett, 'Position', [20, 40, 950, 590], 'BackgroundColor', [0.12, 0.15, 0.22], 'ForegroundColor', [0.7 0.8 1.0], 'Title', 'Stochastic Parameters');
    
    % Presets Switcher
    uilabel(p_sett_card, 'Text', 'Quick Preset Profiles:', 'Position', [30, 520, 180, 25], 'FontColor', [1 1 1], 'FontSize', 14, 'FontWeight', 'bold');
    dd_preset = uidropdown(p_sett_card, 'Items', {'Custom', 'High Volatility Tech/Crypto', 'Stable Low Volatility', 'High Crash Risk Crisis'}, ...
                           'Position', [220, 520, 260, 28], 'BackgroundColor', [0.2 0.25 0.35], 'FontColor', [1 1 1]);

    % Slider 1: S0
    lbl_s_S0 = uilabel(p_sett_card, 'Text', 'Initial Stock Price ($S_0$): $100', 'Position', [30, 440, 300, 25], 'FontColor', [1 1 1], 'FontSize', 13);
    sld_S0 = uislider(p_sett_card, 'Position', [350, 450, 400, 3], 'Limits', [10 500], 'Value', 100, 'FontColor', [1 1 1]);

    % Slider 2: N
    lbl_s_N = uilabel(p_sett_card, 'Text', 'Trading Horizon (Days): 252', 'Position', [30, 360, 300, 25], 'FontColor', [1 1 1], 'FontSize', 13);
    sld_N = uislider(p_sett_card, 'Position', [350, 370, 400, 3], 'Limits', [50 500], 'Value', 252, 'FontColor', [1 1 1]);

    % Slider 3: Drift
    lbl_s_mu = uilabel(p_sett_card, 'Text', 'Annual Drift (\mu): 0.08', 'Position', [30, 280, 300, 25], 'FontColor', [1 1 1], 'FontSize', 13);
    sld_mu = uislider(p_sett_card, 'Position', [350, 290, 400, 3], 'Limits', [-0.5 0.5], 'Value', 0.08, 'FontColor', [1 1 1]);

    % Slider 4: Volatility
    lbl_s_sig = uilabel(p_sett_card, 'Text', 'Annual Volatility (\sigma): 0.12', 'Position', [30, 200, 300, 25], 'FontColor', [1 1 1], 'FontSize', 13);
    sld_sig = uislider(p_sett_card, 'Position', [350, 210, 400, 3], 'Limits', [0.01 0.80], 'Value', 0.12, 'FontColor', [1 1 1]);

    % Slider 5: Threshold
    lbl_s_th = uilabel(p_sett_card, 'Text', 'Variance Alarm Limit (H_1): 0.0015', 'Position', [30, 120, 300, 25], 'FontColor', [1 1 1], 'FontSize', 13);
    sld_th = uislider(p_sett_card, 'Position', [350, 130, 400, 3], 'Limits', [0.0002 0.0100], 'Value', 0.0015, 'FontColor', [1 1 1]);

    % Action Button
    btn_apply_sett = uibutton(p_sett_card, 'Text', 'Apply Settings & Run', 'Position', [30, 30, 220, 45], ...
                              'BackgroundColor', [0.15 0.65 0.35], 'FontColor', [1 1 1], 'FontWeight', 'bold', 'FontSize', 14);

    %% 6. Interactive Event Callbacks
    btn_dash.ButtonPushedFcn   = @(~,~) switchView('dash');
    btn_sim.ButtonPushedFcn    = @(~,~) switchView('sim');
    btn_hist.ButtonPushedFcn   = @(~,~) switchView('hist');
    btn_export.ButtonPushedFcn = @(~,~) openExportDialog();
    btn_sett.ButtonPushedFcn   = @(~,~) switchView('sett');

    btn_run.ButtonPushedFcn       = @(~,~) runSimulation();
    btn_clear_hist.ButtonPushedFcn = @(~,~) clearHistory();
    btn_load_hist.ButtonPushedFcn  = @(~,~) loadHistoricalRun();
    btn_apply_sett.ButtonPushedFcn = @(~,~) applySettings();

    % Slider value change listeners (Real-time labels)
    sld_S0.ValueChangingFcn  = @(~, e) set(lbl_s_S0, 'Text', sprintf('Initial Stock Price ($S_0$): $%.0f', e.Value));
    sld_N.ValueChangingFcn   = @(~, e) set(lbl_s_N, 'Text', sprintf('Trading Horizon (Days): %.0f', e.Value));
    sld_mu.ValueChangingFcn  = @(~, e) set(lbl_s_mu, 'Text', sprintf('Annual Drift (\\mu): %.2f', e.Value));
    sld_sig.ValueChangingFcn = @(~, e) set(lbl_s_sig, 'Text', sprintf('Annual Volatility (\\sigma): %.2f', e.Value));
    sld_th.ValueChangingFcn  = @(~, e) set(lbl_s_th, 'Text', sprintf('Variance Alarm Limit (H_1): %.4f', e.Value));

    dd_preset.ValueChangedFcn = @(~,~) applyPresetProfile();

    % Startup Simulation
    runSimulation();

    %% 7. View Switcher
    function switchView(view_name)
        btns = [btn_dash, btn_sim, btn_hist, btn_export, btn_sett];
        for b = btns; b.BackgroundColor = [0.12, 0.16, 0.24]; end
        v_dash.Visible = 'off'; v_hist.Visible = 'off'; v_sett.Visible = 'off';

        switch view_name
            case 'dash'
                btn_dash.BackgroundColor = [0.15, 0.45, 0.85]; v_dash.Visible = 'on';
            case 'sim'
                btn_sim.BackgroundColor = [0.15, 0.45, 0.85]; v_dash.Visible = 'on';
                runSimulation();
            case 'hist'
                btn_hist.BackgroundColor = [0.15, 0.45, 0.85]; v_hist.Visible = 'on';
            case 'sett'
                btn_sett.BackgroundColor = [0.15, 0.45, 0.85]; v_sett.Visible = 'on';
        end
    end

    %% 8. Native Save File Dialog Callback
    function openExportDialog()
        btn_export.BackgroundColor = [0.15, 0.45, 0.85];
        if run_count == 0 || isempty(history_runs)
            uialert(fig, 'No simulation data available to export. Run a simulation first!', 'Export Error', 'Icon', 'warning');
            return;
        end

        [file, path] = uiputfile({'*.csv', 'CSV File (*.csv)'; '*.xlsx', 'Excel Spreadsheet (*.xlsx)'}, ...
                                 'Export Simulation Results', 'Market_Simulation_Data.csv');
        if isequal(file,0) || isequal(path,0)
            switchView('dash'); return; 
        end

        full_path = fullfile(path, file);
        p = history_runs(end).p;
        v = history_runs(end).v;
        t = (1:length(p))';
        
        export_tbl = table(t, p', v', 'VariableNames', {'Trading_Day', 'Stock_Price_USD', 'Rolling_Variance'});
        writetable(export_tbl, full_path);

        uialert(fig, sprintf('Successfully exported simulation dataset to:\n\n%s', full_path), 'Export Complete', 'Icon', 'success');
        switchView('dash');
    end

    %% 9. Main Stochastic Simulation Engine (PRICE-DIRECTION DRIVEN)
    function runSimulation()
        run_count = run_count + 1;
        params.animate = cb_anim.Value;
        N = round(sld_N.Value);
        S0 = sld_S0.Value;
        dt = 1/252;
        
        current_mu = sld_mu.Value;
        current_sig = sld_sig.Value;

        % 3-State Transition Matrix
        P = [0.85, 0.14, 0.01; 
             0.20, 0.75, 0.05; 
             0.40, 0.30, 0.30];

        % Markov Chain State Generation
        states = zeros(1, N); states(1) = 1;
        for t = 2:N
            r = rand();
            cum_prob = cumsum(P(states(t-1), :));
            states(t) = find(r <= cum_prob, 1, 'first');
        end

        % Drift & Volatility Vector per State
        mu_vec = [current_mu, min(-0.05, current_mu - 0.10), -0.50] * dt;
        sigma_vec = [current_sig, max(current_sig * 1.5, 0.25), max(current_sig * 2.5, 0.50)] * sqrt(dt);
        
        prices = zeros(1, N); prices(1) = S0;
        dW = randn(1, N);

        for t = 2:N
            st = states(t);
            prices(t) = prices(t-1) * exp((mu_vec(st) - 0.5*sigma_vec(st)^2) + sigma_vec(st)*dW(t));
        end

        % Hypothesis Testing for Crash Detection
        window_size = 10; 
        var_est = zeros(1, N); 
        drawdown_est = zeros(1, N);
        crash_detected = false(1, N);

        for t = window_size:N
            w = prices(t-window_size+1:t);
            ret = diff(w) ./ w(1:end-1);
            var_est(t) = var(ret);
            
            peak = max(w);
            drawdown_est(t) = (prices(t) - peak) / peak;

            if var_est(t) > sld_th.Value || drawdown_est(t) < -0.15 || states(t) == 3
                crash_detected(t) = true;
            end
        end

        % Plotting (Animated or Instant)
        cla(ax_plot);
        if params.animate
            h_line = plot(ax_plot, 1, prices(1), 'Color', [0.3 0.6 1.0], 'LineWidth', 1.5);
            hold(ax_plot, 'on'); grid(ax_plot, 'on');
            xlim(ax_plot, [1 N]); ylim(ax_plot, [min(prices)*0.95 max(prices)*1.05]);
            for k = 2:5:N
                h_line.XData = 1:k; h_line.YData = prices(1:k);
                drawnow; pause(0.01);
            end
        else
            plot(ax_plot, 1:N, prices, 'Color', [0.3 0.6 1.0], 'LineWidth', 1.5);
            hold(ax_plot, 'on');
        end

        c_days = find(crash_detected);
        if ~isempty(c_days)
            plot(ax_plot, c_days, prices(c_days), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
        end
        grid(ax_plot, 'on');

        % Update Active Parameter Cards
        lbl_drift.Text = sprintf('Baseline Drift (\\mu): %.2f', current_mu);
        lbl_vol.Text   = sprintf('Volatility (\\sigma): %.2f', current_sig);
        lbl_th.Text    = sprintf('Threshold (H_1): %.4f', sld_th.Value);

        %% REALIZED PRICE DIRECTION CALCULATION
        % Evaluate the actual recent trajectory (last 20% of trading horizon)
        lookback = max(5, floor(N * 0.20));
        p_end = prices(end);
        p_start_window = prices(end - lookback);
        recent_return_pct = ((p_end - p_start_window) / p_start_window) * 100;

        if crash_detected(end) || states(end) == 3
            trend_label = 'CRITICAL CRASH';
            trend_color = [1.0 0.3 0.3];
        elseif recent_return_pct >= 1.5
            trend_label = sprintf('UPWARD BULLISH (+%.1f%%)', recent_return_pct);
            trend_color = [0.3 1.0 0.4];
        elseif recent_return_pct <= -1.5
            trend_label = sprintf('DOWNWARD BEARISH (%.1f%%)', recent_return_pct);
            trend_color = [1.0 0.5 0.2];
        else
            trend_label = sprintf('SIDEWAYS / NEUTRAL (%.1f%%)', recent_return_pct);
            trend_color = [0.9 0.9 0.3];
        end

        lbl_state.Text = trend_label;
        lbl_state.FontColor = trend_color;

        curr_var = var_est(end);
        curr_dd  = drawdown_est(end);
        lbl_var_est.Text = sprintf('Est. Daily Variance: %.6f (10d DD: %.1f%%)', curr_var, curr_dd*100);

        % Risk Gauge Calculation
        var_risk_component = (curr_var / sld_th.Value) * 50;
        dd_risk_component  = min(50, abs(min(0, curr_dd)) / 0.15 * 50);
        total_risk = min(100, var_risk_component + dd_risk_component);

        if crash_detected(end) || states(end) == 3
            lbl_hypo.Text = 'Status: H_1 ACCEPTED (CRASH ALERT!)';
            lbl_hypo.FontColor = [1.0 0.3 0.3];
            gauge.Value = total_risk;
            lbl_risk_val.Text = sprintf('Risk: %.1f%% (CRITICAL)', total_risk);
            lbl_risk_val.FontColor = [1.0 0.3 0.3];
            crash_str = 'YES (H1 Alert)';
        elseif recent_return_pct <= -1.5
            lbl_hypo.Text = 'Status: H_0 Accepted (Realized Downward Slope)';
            lbl_hypo.FontColor = [1.0 0.6 0.2];
            gauge.Value = total_risk;
            lbl_risk_val.Text = sprintf('Risk: %.1f%% (Bearish)', total_risk);
            lbl_risk_val.FontColor = [1.0 0.6 0.2];
            crash_str = 'NO (Bearish Slope)';
        else
            lbl_hypo.Text = 'Status: H_0 Accepted (Market Stable)';
            lbl_hypo.FontColor = [0.3 1.0 0.4];
            gauge.Value = total_risk;
            lbl_risk_val.Text = sprintf('Risk: %.1f%% (Normal)', total_risk);
            lbl_risk_val.FontColor = [0.3 1.0 0.4];
            crash_str = 'NO (H0 Stable)';
        end

        % Store History
        history_runs(run_count).p = prices;
        history_runs(run_count).v = var_est;
        
        new_row = {run_count, dd_asset.Value, sprintf('%.2f', prices(end)), sprintf('%.6f', max(var_est)), trend_label, crash_str};
        history_table_data = [new_row; history_table_data];
        tbl_hist.Data = history_table_data;
    end

    %% 10. History Inspector Callbacks
    function loadHistoricalRun()
        sel = tbl_hist.Selection;
        if isempty(sel)
            uialert(fig, 'Select a row from the table first!', 'Selection Error'); return;
        end
        row_idx = sel(1);
        run_num = tbl_hist.Data{row_idx, 1};
        
        p = history_runs(run_num).p;
        v = history_runs(run_num).v;
        
        switchView('dash');
        cla(ax_plot);
        plot(ax_plot, 1:length(p), p, 'Color', [0.3 0.6 1.0], 'LineWidth', 1.5); hold(ax_plot, 'on');
        c_days = find(v > sld_th.Value);
        if ~isempty(c_days)
            plot(ax_plot, c_days, p(c_days), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
        end
        grid(ax_plot, 'on');
        title(ax_plot, sprintf('Loaded Historical Run #%d Dataset', run_num), 'Color', [0.9 0.9 0.9]);
    end

    function clearHistory()
        history_table_data = {}; history_runs = struct('p', {}, 'v', {}, 'asset', {}, 'state', {}, 'crashed', {});
        run_count = 0; tbl_hist.Data = {};
        uialert(fig, 'All simulation history logs cleared!', 'History Reset');
    end

    %% 11. Settings Callbacks
    function applySettings()
        lbl_drift.Text = sprintf('Baseline Drift (\\mu): %.2f', sld_mu.Value);
        lbl_vol.Text   = sprintf('Volatility (\\sigma): %.2f', sld_sig.Value);
        lbl_th.Text    = sprintf('Threshold (H_1): %.4f', sld_th.Value);
        
        switchView('dash');
        runSimulation();
        uialert(fig, 'New settings applied to simulation!', 'Settings Applied');
    end

    function applyPresetProfile()
        switch dd_preset.Value
            case 'High Volatility Tech/Crypto'
                sld_sig.Value = 0.45; sld_mu.Value = 0.20; sld_th.Value = 0.0040;
            case 'Stable Low Volatility'
                sld_sig.Value = 0.06; sld_mu.Value = 0.05; sld_th.Value = 0.0008;
            case 'High Crash Risk Crisis'
                sld_sig.Value = 0.60; sld_mu.Value = -0.30; sld_th.Value = 0.0020;
        end
        set(lbl_s_sig, 'Text', sprintf('Annual Volatility (\\sigma): %.2f', sld_sig.Value));
        set(lbl_s_mu, 'Text', sprintf('Annual Drift (\\mu): %.2f', sld_mu.Value));
        set(lbl_s_th, 'Text', sprintf('Variance Alarm Limit (H_1): %.4f', sld_th.Value));
    end
end
