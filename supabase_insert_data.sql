-- ==============================================================================
-- INSERT DATA SCRIPT - AntLogger V1.3
-- ==============================================================================
-- Este script inserta los datos históricos del archivo Markdown en Supabase.
-- Se asume que el DEVICE_UUID es '6815b981-47cb-47be-acbd-d06514d2228c'.
-- ==============================================================================

DO $$
DECLARE
    v_device_id UUID := '6815b981-47cb-47be-acbd-d06514d2228c';
    v_phase1_id UUID;
    v_phase2_id UUID;
    v_phase3_id UUID;
    v_phase4_id UUID;
    v_phase5_id UUID;
BEGIN

    -- --------------------------------------------------------------------------
    -- 1. Insertar FASES EVOLUTIVAS
    -- --------------------------------------------------------------------------
    
    -- Fase 1
    INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date, is_active)
    VALUES (v_device_id, 'Fase 1 - Inicio frío y ajustes hídricos', 'Baja actividad por frío (~16°C). Problemas iniciales de humedad y moho. Corrección del sistema hídrico.', '2026-02-01 00:00:00+00', '2026-02-10 23:59:59+00', false)
    RETURNING id INTO v_phase1_id;

    -- Fase 2
    INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date, is_active)
    VALUES (v_device_id, 'Fase 2 - Transición estructural', 'Nuevo forrajeo seco instalado. Uso del tubo como vertedero. Mortalidad aislada.', '2026-02-11 00:00:00+00', '2026-02-21 23:59:59+00', false)
    RETURNING id INTO v_phase2_id;

    -- Fase 3
    INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date, is_active)
    VALUES (v_device_id, 'Fase 3 - Cambio de fase estructural', 'Excavación masiva sostenida. Formación de túnel vertical significativo. Pico de actividad.', '2026-02-22 00:00:00+00', '2026-02-22 23:59:59+00', false)
    RETURNING id INTO v_phase3_id;

    -- Fase 4
    INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date, is_active)
    VALUES (v_device_id, 'Fase 4 - Consolidación activa', 'Actividad distribuida en oleadas. Ventanas nocturnas recurrentes. Metabolismo estable.', '2026-02-23 00:00:00+00', '2026-02-26 23:59:59+00', false)
    RETURNING id INTO v_phase4_id;

    -- Fase 5 (Actual)
    INSERT INTO public.colony_phases (device_id, name, description, start_date, end_date, is_active)
    VALUES (v_device_id, 'Fase 5 - Activación nocturna prolongada', 'Actividad continua desde la madrugada. Más de 100 clips por detección de movimiento.', '2026-02-27 00:00:00+00', NULL, true)
    RETURNING id INTO v_phase5_id;


    -- --------------------------------------------------------------------------
    -- 2. Insertar EVENTOS y OBSERVACIONES
    -- (Asignamos horas aproximadas para eventos generales, y específicas si existen)
    -- --------------------------------------------------------------------------

    -- Eventos Fase 1
    INSERT INTO public.colony_events (device_id, phase_id, event_type, description, observed_at, tags) VALUES
    (v_device_id, v_phase1_id, 'OBSERVATION', 'Baja actividad por frío (~16°C)', '2026-02-02 12:00:00+00', ARRAY['temperatura', 'inactividad']),
    (v_device_id, v_phase1_id, 'MAINTENANCE', 'Problemas iniciales de humedad y aparición de moho', '2026-02-05 10:00:00+00', ARRAY['moho', 'humedad']),
    (v_device_id, v_phase1_id, 'MAINTENANCE', 'Corrección del sistema hídrico', '2026-02-06 16:00:00+00', ARRAY['agua', 'mantenimiento']),
    (v_device_id, v_phase1_id, 'FORAGING', 'Reactivación progresiva con proteína', '2026-02-08 14:00:00+00', ARRAY['comida', 'proteina']);

    -- Eventos Fase 2
    INSERT INTO public.colony_events (device_id, phase_id, event_type, description, observed_at, tags) VALUES
    (v_device_id, v_phase2_id, 'MAINTENANCE', 'Nuevo forrajeo seco instalado', '2026-02-12 11:00:00+00', ARRAY['forrajeo', 'instalacion']),
    (v_device_id, v_phase2_id, 'OBSERVATION', 'Uso del tubo como vertedero', '2026-02-14 09:00:00+00', ARRAY['vertedero', 'comportamiento']),
    (v_device_id, v_phase2_id, 'MORTALITY', 'Mortalidad aislada (1 obrera) sin patrón posterior', '2026-02-15 10:00:00+00', ARRAY['mortalidad', 'baja']),
    (v_device_id, v_phase2_id, 'EXCAVATION', 'Excavación intermitente en bloques', '2026-02-18 15:00:00+00', ARRAY['excavacion', 'tuneles']);

    -- Eventos Fase 3
    INSERT INTO public.colony_events (device_id, phase_id, event_type, description, observed_at, intensity, tags) VALUES
    (v_device_id, v_phase3_id, 'EXCAVATION', 'Excavación masiva sostenida', '2026-02-22 10:00:00+00', 5, ARRAY['excavacion', 'masiva']),
    (v_device_id, v_phase3_id, 'EXCAVATION', 'Formación de túnel vertical significativo', '2026-02-22 14:00:00+00', 4, ARRAY['tunel', 'construccion']),
    (v_device_id, v_phase3_id, 'OBSERVATION', 'Pico de hasta 7 obreras simultáneamente', '2026-02-22 16:00:00+00', 5, ARRAY['actividad', 'censo']);

    -- Eventos Fase 4
    INSERT INTO public.colony_events (device_id, phase_id, event_type, description, observed_at, intensity, tags) VALUES
    (v_device_id, v_phase4_id, 'OBSERVATION', 'Ventanas nocturnas recurrentes (21:30--22:40)', '2026-02-24 21:30:00+00', 4, ARRAY['nocturno', 'ritmo']),
    (v_device_id, v_phase4_id, 'EXCAVATION', 'Extracción de terrones compactos', '2026-02-25 22:00:00+00', 3, ARRAY['excavacion', 'terrones']),
    (v_device_id, v_phase4_id, 'OBSERVATION', 'Reutilización parcial del tubo como zona de depósito', '2026-02-26 09:00:00+00', 2, ARRAY['vertedero', 'comportamiento']);

    -- Eventos Fase 5
    INSERT INTO public.colony_events (device_id, phase_id, event_type, description, observed_at, intensity, tags) VALUES
    (v_device_id, v_phase5_id, 'OBSERVATION', 'Actividad continua desde la madrugada', '2026-02-27 04:00:00+00', 5, ARRAY['actividad', 'madrugada']),
    (v_device_id, v_phase5_id, 'OBSERVATION', 'Más de 100 clips por detección de movimiento', '2026-02-27 08:00:00+00', 5, ARRAY['camara', 'movimiento']),
    (v_device_id, v_phase5_id, 'OBSERVATION', 'Pausa diurna tras bloque nocturno largo', '2026-02-27 12:00:00+00', 1, ARRAY['descanso', 'ritmo']);


    -- --------------------------------------------------------------------------
    -- 3. Insertar INDICADORES (Snapshot a 27/02)
    -- --------------------------------------------------------------------------
    INSERT INTO public.colony_indicators (device_id, recorded_at, mortality_count, mold_status, water_system_status, risk_level, notes)
    VALUES (
        v_device_id,
        '2026-02-27 12:00:00+00',
        1, -- Mortalidad: 1 obrera aislada
        'RESOLVED', -- Moho: Resuelto
        'STABLE', -- Sistema hídrico: Estable
        'LOW', -- Riesgo actual: Bajo
        'Patrón dominante: Actividad en bloques con ventana nocturna consolidada. Fase actual: Activa pre-primaveral.'
    );

END $$;
