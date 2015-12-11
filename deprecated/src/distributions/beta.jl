#------------------------------------------------------# Type and Constructors
type FitBeta{W <: Weighting} <: DistributionStat
    d::Dist.Beta
    stats::Variance{W}
    n::Int64
    weighting::W
end

function distributionfit(::Type{Dist.Beta}, y::AVecF, wgt::Weighting = default(Weighting))
    o = FitBeta(wgt)
    update!(o, y)
    o
end

FitBeta{T <: Real}(y::AVec{T}, wgt::Weighting = default(Weighting)) =
    distributionfit(Dist.Beta, y, wgt)

FitBeta(wgt::Weighting = default(Weighting)) =
    FitBeta(Dist.Beta(), Variance(wgt), 0, wgt)


#---------------------------------------------------------------------# update!
function update!(obj::FitBeta, y::Real)
    update!(obj.stats, y)  # Weighting is applied to updating Variance
    m = mean(obj.stats)
    v = var(obj.stats)
    α = m * (m * (1 - m) / v - 1)
    β = (1 - m) * (m * (1 - m) / v - 1)

    if α <= 0
        α = .01
    end
    if β <= 0
        β = .01
    end

    obj.d = Dist.Beta(α, β)
    obj.n += 1
end