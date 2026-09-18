#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(QString, display)]
        #[qproperty(QString, mode)]
        #[qproperty(QString, pending_operator)]
        #[qproperty(f64, current_value)]
        #[qproperty(bool, reset_on_next_input)]
        #[qproperty(QString, keyboard_expr)]
        #[qproperty(QString, radix)]
        #[qproperty(QString, result_format)]
        type Calculator = super::CalculatorRust;

        #[qinvokable] fn input_digit(self: Pin<&mut Self>, digit: &QString);
        #[qinvokable] fn input_decimal(self: Pin<&mut Self>);
        #[qinvokable] fn toggle_sign(self: Pin<&mut Self>);
        #[qinvokable] fn percentage(self: Pin<&mut Self>);
        #[qinvokable] fn backspace(self: Pin<&mut Self>);
        #[qinvokable] fn clear_entry(self: Pin<&mut Self>);
        #[qinvokable] fn clear_all(self: Pin<&mut Self>);
        #[qinvokable] fn clear_history(self: Pin<&mut Self>);
        #[qinvokable] fn set_operator(self: Pin<&mut Self>, op: &QString);
        #[qinvokable] fn calculate(self: Pin<&mut Self>);
        #[qinvokable] fn change_mode(self: Pin<&mut Self>, mode: &QString);
        #[qinvokable] fn change_result_format(self: Pin<&mut Self>, fmt: &QString);
        #[qinvokable] fn apply_unary(self: Pin<&mut Self>, func: &QString);
        #[qinvokable] fn insert_constant(self: Pin<&mut Self>, constant: &QString);
        #[qinvokable] fn evaluate_keyboard(self: Pin<&mut Self>);
        #[qinvokable] fn update_keyboard_expr(self: Pin<&mut Self>, expr: &QString);
        #[qinvokable] fn programming_op(self: Pin<&mut Self>, op: &QString);
        #[qinvokable] fn change_radix(self: Pin<&mut Self>, radix: &QString);
        #[qinvokable] fn financial(self: Pin<&mut Self>, func: &QString, args: &QString);
        #[qinvokable] fn convert(self: Pin<&mut Self>, category: &QString, from: &QString, to: &QString, value: f64);
    }
}

use core::pin::Pin;
use cxx_qt_lib::QString;

pub struct CalculatorRust {
    display: QString,
    mode: QString,
    pending_operator: QString,
    current_value: f64,
    reset_on_next_input: bool,
    keyboard_expr: QString,
    radix: QString,
    result_format: QString,
}

impl Default for CalculatorRust {
    fn default() -> Self {
        Self {
            display: QString::from("0"),
            mode: QString::from("Basic"),
            pending_operator: QString::from(""),
            current_value: 0.0,
            reset_on_next_input: true,
            keyboard_expr: QString::from(""),
            radix: QString::from("DEC"),
            result_format: QString::from("Automatic"),
        }
    }
}

impl qobject::Calculator {
    pub fn input_digit(mut self: Pin<&mut Self>, digit: &QString) {
        let d = match digit.to_string().parse::<char>() { Ok(c) => c, Err(_) => return };
        let mut disp = self.display().to_string();
        let mut reset = *self.reset_on_next_input();
        if reset { disp = d.to_string(); reset = false; }
        else if disp == "0" { disp = d.to_string(); }
        else if disp.len() < 16 { disp.push(d); }
        self.as_mut().set_display(QString::from(&disp));
        self.as_mut().set_reset_on_next_input(reset);
    }

    pub fn input_decimal(mut self: Pin<&mut Self>) {
        let disp = self.display().to_string();
        let reset = *self.reset_on_next_input();
        if reset {
            self.as_mut().set_display(QString::from("0."));
            self.as_mut().set_reset_on_next_input(false);
        } else if !disp.contains('.') {
            self.as_mut().set_display(QString::from(&(disp + ".")));
        }
    }

    pub fn toggle_sign(mut self: Pin<&mut Self>) {
        let disp = self.display().to_string();
        if disp == "0" || disp == "Error" { return; }
        if let Some(s) = disp.strip_prefix('-') {
            self.as_mut().set_display(QString::from(s));
        } else {
            self.as_mut().set_display(QString::from(&format!("-{}", disp)));
        }
    }

    pub fn percentage(mut self: Pin<&mut Self>) {
        if let Ok(v) = self.display().to_string().parse::<f64>() {
            let out = self.fmt(v / 100.0);
            self.as_mut().set_display(QString::from(&out));
            self.as_mut().set_reset_on_next_input(true);
        }
    }

    pub fn backspace(mut self: Pin<&mut Self>) {
        if *self.reset_on_next_input() { return; }
        let mut disp = self.display().to_string();
        if disp.len() > 1 {
            disp.pop();
            if disp == "-" { disp = "0".into(); }
        } else { disp = "0".into(); }
        self.as_mut().set_display(QString::from(&disp));
    }

    pub fn clear_entry(mut self: Pin<&mut Self>) {
        self.as_mut().set_display(QString::from("0"));
        self.as_mut().set_reset_on_next_input(true);
    }

    pub fn clear_all(mut self: Pin<&mut Self>) {
        self.as_mut().set_display(QString::from("0"));
        self.as_mut().set_current_value(0.0);
        self.as_mut().set_pending_operator(QString::from(""));
        self.as_mut().set_reset_on_next_input(true);
        self.as_mut().set_keyboard_expr(QString::from(""));
    }

    pub fn clear_history(mut self: Pin<&mut Self>) {
        self.as_mut().set_current_value(0.0);
        self.as_mut().set_pending_operator(QString::from(""));
    }

    pub fn set_operator(mut self: Pin<&mut Self>, op: &QString) {
        let disp = self.display().to_string();
        if disp == "Error" { return; }
        let v: f64 = match disp.parse() { Ok(x) => x, Err(_) => return };
        let pending = self.pending_operator().to_string();
        let cur = *self.current_value();
        if !pending.is_empty() {
            match compute(cur, v, &pending) {
                Some(r) => {
                    let out = self.fmt(r);
                    self.as_mut().set_current_value(r);
                    self.as_mut().set_display(QString::from(&out));
                }
                None => {
                    self.as_mut().set_display(QString::from("Error"));
                    self.as_mut().set_pending_operator(QString::from(""));
                    self.as_mut().set_current_value(0.0);
                    self.as_mut().set_reset_on_next_input(true);
                    return;
                }
            }
        } else {
            self.as_mut().set_current_value(v);
        }
        self.as_mut().set_pending_operator(op.clone());
        self.as_mut().set_reset_on_next_input(true);
    }

    pub fn calculate(mut self: Pin<&mut Self>) {
        let disp = self.display().to_string();
        if disp == "Error" { return; }
        let pending = self.pending_operator().to_string();
        if pending.is_empty() { return; }
        if let Ok(v) = disp.parse::<f64>() {
            let cur = *self.current_value();
            match compute(cur, v, &pending) {
                Some(r) => {
                    let out = self.fmt(r);
                    self.as_mut().set_display(QString::from(&out));
                    self.as_mut().set_current_value(r);
                }
                None => {
                    self.as_mut().set_display(QString::from("Error"));
                    self.as_mut().set_current_value(0.0);
                }
            }
        }
        self.as_mut().set_pending_operator(QString::from(""));
        self.as_mut().set_reset_on_next_input(true);
    }

    pub fn change_mode(mut self: Pin<&mut Self>, mode: &QString) {
        self.as_mut().set_mode(mode.clone());
        self.as_mut().set_display(QString::from("0"));
        self.as_mut().set_current_value(0.0);
        self.as_mut().set_pending_operator(QString::from(""));
        self.as_mut().set_reset_on_next_input(true);
        self.as_mut().set_keyboard_expr(QString::from(""));
    }

    pub fn change_result_format(mut self: Pin<&mut Self>, fmt: &QString) {
        self.as_mut().set_result_format(fmt.clone());
        if let Ok(v) = self.display().to_string().parse::<f64>() {
            let out = self.fmt(v);
            self.as_mut().set_display(QString::from(&out));
        }
    }

    pub fn apply_unary(mut self: Pin<&mut Self>, func: &QString) {
        let disp = self.display().to_string();
        let v: f64 = match disp.parse() { Ok(x) => x, Err(_) => return };
        let result = match func.to_string().as_str() {
            "sin" => v.to_radians().sin(),
            "cos" => v.to_radians().cos(),
            "tan" => v.to_radians().tan(),
            "asin" => v.asin().to_degrees(),
            "acos" => v.acos().to_degrees(),
            "atan" => v.atan().to_degrees(),
            "sinh" => v.sinh(),
            "cosh" => v.cosh(),
            "tanh" => v.tanh(),
            "ln" => v.ln(),
            "log" => v.log10(),
            "sqrt" => v.sqrt(),
            "sqr" => v * v,
            "cube" => v * v * v,
            "inv" => 1.0 / v,
            "abs" => v.abs(),
            "fact" => factorial(v),
            "not" => !(v as i64) as f64,
            "neg" => -v,
            _ => v,
        };
        let out = self.fmt(result);
        self.as_mut().set_display(QString::from(&out));
        self.as_mut().set_reset_on_next_input(true);
    }

    pub fn insert_constant(mut self: Pin<&mut Self>, constant: &QString) {
        let val = match constant.to_string().as_str() {
            "pi" => std::f64::consts::PI,
            "e" => std::f64::consts::E,
            "phi" => 1.618033988749895,
            "rand" => rand_f64(),
            _ => return,
        };
        let out = self.fmt(val);
        self.as_mut().set_display(QString::from(&out));
        self.as_mut().set_reset_on_next_input(true);
    }

    pub fn update_keyboard_expr(mut self: Pin<&mut Self>, expr: &QString) {
        self.as_mut().set_keyboard_expr(expr.clone());
    }

    pub fn evaluate_keyboard(mut self: Pin<&mut Self>) {
        let expr = self.keyboard_expr().to_string();
        match eval_expr(&expr) {
            Ok(v) => {
                let out = self.fmt(v);
                self.as_mut().set_display(QString::from(&out));
                self.as_mut().set_reset_on_next_input(true);
            }
            Err(e) => {
                self.as_mut().set_display(QString::from(&format!("Error: {}", e)));
                self.as_mut().set_reset_on_next_input(true);
            }
        }
    }

    pub fn programming_op(mut self: Pin<&mut Self>, op: &QString) {
        self.as_mut().set_operator(op);
    }

    pub fn change_radix(mut self: Pin<&mut Self>, radix: &QString) {
        let new_radix = radix.to_string();
        if let Ok(v) = self.display().to_string().parse::<f64>() {
            let as_int = v as i64;
            let formatted = match new_radix.as_str() {
                "HEX" => format!("{:X}", as_int),
                "OCT" => format!("{:o}", as_int),
                "BIN" => format!("{:b}", as_int),
                _ => format!("{}", as_int),
            };
            self.as_mut().set_display(QString::from(&formatted));
        }
        self.as_mut().set_radix(QString::from(&new_radix));
    }

    pub fn financial(mut self: Pin<&mut Self>, func: &QString, args: &QString) {
        let f = func.to_string();
        let parts: Vec<f64> = args
            .to_string()
            .split(',')
            .filter_map(|s| s.trim().parse::<f64>().ok())
            .collect();
        let result = match f.as_str() {
            "pmt" if parts.len() >= 3 => {
                let (rate, nper, pv) = (parts[0], parts[1], parts[2]);
                if rate == 0.0 { -pv / nper }
                else { -rate * pv / (1.0 - (1.0 + rate).powf(-nper)) }
            }
            "fv" if parts.len() >= 3 => {
                let (rate, nper, pmt) = (parts[0], parts[1], parts[2]);
                if rate == 0.0 { -pmt * nper }
                else { -pmt * ((1.0 + rate).powf(nper) - 1.0) / rate }
            }
            "pv" if parts.len() >= 3 => {
                let (rate, nper, pmt) = (parts[0], parts[1], parts[2]);
                if rate == 0.0 { -pmt * nper }
                else { -pmt * (1.0 - (1.0 + rate).powf(-nper)) / rate }
            }
            "rate" if parts.len() >= 3 => {
                let (nper, pmt, pv) = (parts[0], parts[1], parts[2]);
                let mut r: f64 = 0.1;
                for _ in 0..80 {
                    let fv = pv * (1.0 + r).powf(nper) + pmt * ((1.0 + r).powf(nper) - 1.0) / r;
                    let dfv = nper * pv * (1.0 + r).powf(nper - 1.0)
                        + pmt * (nper * r * (1.0 + r).powf(nper - 1.0) - ((1.0 + r).powf(nper) - 1.0)) / (r * r);
                    if dfv.abs() < 1e-14 { break; }
                    let step = fv / dfv;
                    r -= step;
                    if step.abs() < 1e-12 { break; }
                }
                r
            }
            "nper" if parts.len() >= 3 => {
                let (rate, pmt, pv) = (parts[0], parts[1], parts[2]);
                if rate == 0.0 { -pv / pmt }
                else { (pmt / rate - pv).ln() / (1.0 + rate).ln() }
            }
            "ddb" if parts.len() >= 4 => {
                let (cost, salvage, life, period) = (parts[0], parts[1], parts[2], parts[3]);
                let rate = 2.0 / life;
                let mut value = cost;
                let mut dep = 0.0;
                for p in 1..=(period as u32) {
                    dep = (value * rate).min(value - salvage);
                    if p < period as u32 { value -= dep; }
                }
                dep
            }
            "sln" if parts.len() >= 3 => (parts[0] - parts[1]) / parts[2],
            "syd" if parts.len() >= 4 => {
                let (cost, salvage, life, period) = (parts[0], parts[1], parts[2], parts[3]);
                (cost - salvage) * (life - period + 1.0) * 2.0 / (life * (life + 1.0))
            }
            "gpm" if parts.len() >= 2 => (parts[0] - parts[1]) / parts[0] * 100.0,
            "ctrm" if parts.len() >= 3 => {
                let (rate, pv, pmt) = (parts[0], parts[1], parts[2]);
                if rate == 0.0 { pv / pmt }
                else { (1.0 / (1.0 - rate * pv / pmt)).ln() / (1.0 + rate).ln() }
            }
            _ => return,
        };
        let out = self.fmt(result);
        self.as_mut().set_display(QString::from(&out));
        self.as_mut().set_reset_on_next_input(true);
    }

    pub fn convert(mut self: Pin<&mut Self>, category: &QString, from: &QString, to: &QString, value: f64) {
        let cat = category.to_string();
        let f = from.to_string();
        let t = to.to_string();
        let result = match cat.as_str() {
            "Length" => convert_length(&f, &t, value),
            "Mass" => convert_mass(&f, &t, value),
            "Temperature" => convert_temp(&f, &t, value),
            "Time" => convert_time(&f, &t, value),
            _ => value,
        };
        let out = self.fmt(result);
        self.as_mut().set_display(QString::from(&out));
        self.as_mut().set_reset_on_next_input(true);
    }

    fn fmt(&self, v: f64) -> String {
        if v.is_nan() || v.is_infinite() {
            return "Error".to_string();
        }
        let format = self.result_format().to_string();
        match format.as_str() {
            "Fixed" => format!("{:.2}", v),
            "Scientific" => format!("{:.6e}", v),
            "Engineering" => {
                if v == 0.0 { return "0".to_string(); }
                let exp = v.abs().log10().floor() as i32;
                let eng_exp = (exp.div_euclid(3)) * 3;
                let mantissa = v / 10f64.powi(eng_exp);
                format!("{:.6}e{:+03}", mantissa, eng_exp)
            }
            _ => {
                let mut s = format!("{:.15}", v);
                if s.contains('.') {
                    s = s.trim_end_matches('0').trim_end_matches('.').to_string();
                }
                if s.is_empty() || s == "-" { s = "0".to_string(); }
                s
            }
        }
    }
}

fn convert_length(from: &str, to: &str, v: f64) -> f64 {
    let to_m = |u: &str, x: f64| -> f64 {
        match u {
            "mm" => x / 1000.0, "cm" => x / 100.0, "m" => x, "km" => x * 1000.0,
            "in" => x * 0.0254, "ft" => x * 0.3048, "yd" => x * 0.9144, "mi" => x * 1609.344,
            _ => x,
        }
    };
    let from_m = |u: &str, x: f64| -> f64 {
        match u {
            "mm" => x * 1000.0, "cm" => x * 100.0, "m" => x, "km" => x / 1000.0,
            "in" => x / 0.0254, "ft" => x / 0.3048, "yd" => x / 0.9144, "mi" => x / 1609.344,
            _ => x,
        }
    };
    from_m(to, to_m(from, v))
}

fn convert_mass(from: &str, to: &str, v: f64) -> f64 {
    let to_kg = |u: &str, x: f64| -> f64 {
        match u {
            "mg" => x / 1e6, "g" => x / 1000.0, "kg" => x, "t" => x * 1000.0,
            "oz" => x * 0.0283495, "lb" => x * 0.453592, "st" => x * 6.35029,
            _ => x,
        }
    };
    let from_kg = |u: &str, x: f64| -> f64 {
        match u {
            "mg" => x * 1e6, "g" => x * 1000.0, "kg" => x, "t" => x / 1000.0,
            "oz" => x / 0.0283495, "lb" => x / 0.453592, "st" => x / 6.35029,
            _ => x,
        }
    };
    from_kg(to, to_kg(from, v))
}

fn convert_temp(from: &str, to: &str, v: f64) -> f64 {
    let to_c = |u: &str, x: f64| -> f64 {
        match u { "C" => x, "F" => (x - 32.0) * 5.0 / 9.0, "K" => x - 273.15, _ => x }
    };
    let from_c = |u: &str, x: f64| -> f64 {
        match u { "C" => x, "F" => x * 9.0 / 5.0 + 32.0, "K" => x + 273.15, _ => x }
    };
    from_c(to, to_c(from, v))
}

fn convert_time(from: &str, to: &str, v: f64) -> f64 {
    let to_s = |u: &str, x: f64| -> f64 {
        match u {
            "ms" => x / 1000.0, "s" => x, "min" => x * 60.0,
            "h" => x * 3600.0, "day" => x * 86400.0, "week" => x * 604800.0, _ => x,
        }
    };
    let from_s = |u: &str, x: f64| -> f64 {
        match u {
            "ms" => x * 1000.0, "s" => x, "min" => x / 60.0,
            "h" => x / 3600.0, "day" => x / 86400.0, "week" => x / 604800.0, _ => x,
        }
    };
    from_s(to, to_s(from, v))
}

fn eval_expr(s: &str) -> Result<f64, String> {
    let chars: Vec<char> = s.chars().filter(|c| !c.is_whitespace()).collect();
    let mut pos = 0;
    let result = parse_expr(&chars, &mut pos)?;
    if pos != chars.len() { return Err("Syntax error".into()); }
    Ok(result)
}

fn parse_expr(c: &[char], p: &mut usize) -> Result<f64, String> {
    let mut left = parse_term(c, p)?;
    while *p < c.len() && (c[*p] == '+' || c[*p] == '-') {
        let op = c[*p]; *p += 1;
        let right = parse_term(c, p)?;
        left = if op == '+' { left + right } else { left - right };
    }
    Ok(left)
}

fn parse_term(c: &[char], p: &mut usize) -> Result<f64, String> {
    let mut left = parse_power(c, p)?;
    while *p < c.len() && (c[*p] == '*' || c[*p] == '/' || c[*p] == '%') {
        let op = c[*p]; *p += 1;
        let right = parse_power(c, p)?;
        left = match op {
            '*' => left * right,
            '/' => {
                if right == 0.0 { return Err("Division by zero".into()); }
                left / right
            }
            '%' => left % right,
            _ => unreachable!(),
        };
    }
    Ok(left)
}

fn parse_power(c: &[char], p: &mut usize) -> Result<f64, String> {
    let base = parse_unary(c, p)?;
    if *p < c.len() && c[*p] == '^' {
        *p += 1;
        let exp = parse_power(c, p)?;
        return Ok(base.powf(exp));
    }
    Ok(base)
}

fn parse_unary(c: &[char], p: &mut usize) -> Result<f64, String> {
    if *p < c.len() && c[*p] == '-' { *p += 1; return Ok(-parse_unary(c, p)?); }
    if *p < c.len() && c[*p] == '+' { *p += 1; return parse_unary(c, p); }
    parse_atom(c, p)
}

fn parse_atom(c: &[char], p: &mut usize) -> Result<f64, String> {
    if *p >= c.len() { return Err("Unexpected end".into()); }
    if c[*p] == '(' {
        *p += 1;
        let v = parse_expr(c, p)?;
        if *p >= c.len() || c[*p] != ')' { return Err("Missing )".into()); }
        *p += 1;
        return Ok(v);
    }
    let start = *p;
    while *p < c.len() && (c[*p].is_ascii_digit() || c[*p] == '.') { *p += 1; }
    if start == *p {
        let fs = *p;
        while *p < c.len() && c[*p].is_ascii_alphabetic() { *p += 1; }
        let name: String = c[fs..*p].iter().collect();
        if name.is_empty() { return Err("Unexpected character".into()); }
        match name.as_str() {
            "pi" => return Ok(std::f64::consts::PI),
            "e" => return Ok(std::f64::consts::E),
            _ => {}
        }
        if *p >= c.len() || c[*p] != '(' { return Err(format!("Unknown: {}", name)); }
        *p += 1;
        let arg = parse_expr(c, p)?;
        if *p >= c.len() || c[*p] != ')' { return Err("Missing )".into()); }
        *p += 1;
        return match name.as_str() {
            "sin" => Ok(arg.to_radians().sin()),
            "cos" => Ok(arg.to_radians().cos()),
            "tan" => Ok(arg.to_radians().tan()),
            "sqrt" => Ok(arg.sqrt()),
            "ln" => Ok(arg.ln()),
            "log" => Ok(arg.log10()),
            "abs" => Ok(arg.abs()),
            _ => Err(format!("Unknown function: {}", name)),
        };
    }
    let s: String = c[start..*p].iter().collect();
    s.parse::<f64>().map_err(|_| format!("Bad number: {}", s))
}

fn rand_f64() -> f64 {
    use std::time::{SystemTime, UNIX_EPOCH};
    let nanos = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().subsec_nanos();
    (nanos as f64) / 1_000_000_000.0
}

fn compute(a: f64, b: f64, op: &str) -> Option<f64> {
    match op {
        "+" => Some(a + b),
        "-" => Some(a - b),
        "*" | "×" => Some(a * b),
        "/" | "÷" => if b == 0.0 { None } else { Some(a / b) },
        "^" => Some(a.powf(b)),
        "AND" => Some(((a as i64) & (b as i64)) as f64),
        "OR" => Some(((a as i64) | (b as i64)) as f64),
        "XOR" => Some(((a as i64) ^ (b as i64)) as f64),
        "<<" => Some(((a as i64) << (b as i64)) as f64),
        ">>" => Some(((a as i64) >> (b as i64)) as f64),
        _ => None,
    }
}

fn factorial(n: f64) -> f64 {
    if n < 0.0 || n.fract() != 0.0 { return f64::NAN; }
    (1..=(n as u64)).fold(1.0, |acc, x| acc * x as f64)
}
